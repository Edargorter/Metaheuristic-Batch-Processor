##### Multipurpose Batch Plant Simulator (Primary Example) ##### Zachary Bowditch 2019 #####

#= 
	
	Contents (Unique Search Strings):

	Section								Key (search)

	1) Included files/libraries			incl
	2) Helper functions:				hfuncs
	3) Fitness Function:				fitfunc

=#

### key=incl Included Files and Libraries ###

using Printf
include("mbp_structs.jl")

# Evaluate fitness of a candidate Batch Processing Schedule (fitness metric = final state quantity)

### key=hfuncs Helper Functions ###

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

# Flush the contents of the unit into receiving storages according to distribution ratio
function flush(config::MBP_Config, state::MBP_State, unit::Int, event::Int, instruction::Int)	
	active::Int = state.unit_active[unit, event - 1] #Flush from action (task)

	if active == 0 return end
	if instruction == 0 return end

	# Get receiving storages
	unit_amount::Float64 = state.unit_amounts[unit, event]

	if unit_amount == 0 return end

	receivers::Dict{Int, Float64} = config.tasks[active].receivers
	amount::Float64 = unit_amount

	for (receiver, fraction) in receivers
	
		recv_cap = config.storages[receiver].capacity
		recv_amount = state.storage_amounts[receiver]

		if (recv_cap - recv_amount) < (amount * fraction)
			amount = (recv_cap - recv_amount) / fraction
		end

	end

	for (receiver, fraction) in receivers 
		state.storage_amounts[receiver] += fraction * amount
	end
	state.unit_amounts[unit, event] = unit_amount - amount 
end

### key=fitfunc FITNESS FUNCTION ###

function get_fitness(config::MBP_Config, params::Params, candidate::MBP_Program, print_data::Bool=false)
	# If sum of durations of candidate exceeds horizon, candidate is nullified

	if round(sum(candidate.durations), digits=4) > params.horizon return 0 end

	if print_data
		@printf "Instructions: "
		print(candidate.instructions)
		newline()
		@printf "Durations: "
		print(candidate.durations)
		newline(2)
	end

	# Set initial state parameters
	unit_amounts::Array{Float64, 2} = zeros(config.no_units, params.no_events + 1)
	unit_activated::Array{Int, 2} = zeros(config.no_units, params.no_events + 1)

	# Default state
	state::MBP_State = MBP_State(unit_amounts, unit_activated, copy(config.initial_volumes))

	storages::Array{MBP_Storage} = config.storages

	if print_data
		@printf "State unit_active size: "
		print(size(state.unit_active))
		newline()

		@printf "State unit_amounts size: "
		print(size(state.unit_amounts))
		newline()
	end

	task_duration::Float64 = 0.0 # Temp variable for task length in unit of time (e.g. hours) 

	# Initial declarations 

	recv_amount::Float64 = 0.0
	recv_cap::Float64 = 0.0

	# Unit parameters
	alpha::Float64 = 0.0
	beta::Float64 = 0.0
	unit_capacity::Float64 = 0.0
	unit_amount::Float64 = 0.0

	active::Int = 0
	duration::Float64 = 0.0
	available::Float64 = 0.0

	instruction::Int = 0
	amount::Float64 = 0.0
	max_reached::Bool = false

	prev_unit_amount::Float64 = 0.0
	prev_feeder::Int = 0

	# Iterate through events
	for event in 1:params.no_events

		if print_data	
			@printf "=============== EVENT %d ===============" event
			newline(2)
		end

		# Flush units if possible
		if event > 1
			for unit in 1:config.no_units
				flush(config, state, unit, event, candidate.instructions[unit, event])
			end
		end

		if print_data
			@printf "Unit amounts: "
			for us in 1:config.no_units
				@printf "%.2f " state.unit_amounts[us, event] 
			end
			newline()
			@printf "Storage amounts: "
			for us in 1:config.no_storages
				@printf "%.2f " state.storage_amounts[us]
			end
			newline(2)
		end

		# Iterate through units
		for unit in 1:config.no_units

			if print_data @printf "Event: %d [ %.3f ] Unit: %d Name: %s\n" event candidate.durations[event] unit config.units[unit].name end

			# Unit parameters
			tasks::Dict{Int, MBP_Coefs} = config.units[unit].tasks

			if print_data
				newline()
				print(keys(tasks))
				newline()
			end

			unit_capacity = config.units[unit].capacity
			unit_amount = state.unit_amounts[unit, event]
			prev_unit_amount = 0.0

			active = state.unit_active[unit, event]

			duration = candidate.durations[event]
			available = unit_capacity

			instruction = candidate.instructions[unit, event]	

			# Instruction 0 (Continue task if one exists)
			if instruction == 0
				
				# Pass on values 
				state.unit_amounts[unit, event + 1] = unit_amount

				if print_data newline() end

			# Instruction != 0 (Start new task if possible)
			elseif instruction in keys(tasks)

				# Get feeding/receiving storage containments
				feeders = config.tasks[instruction].feeders
				receivers = config.tasks[instruction].receivers

				# Take residue state from previous unit 
				if length(feeders) == 1 # If unit has only a single storage feed

					# If that single feeder has a single unit feeder 
					prev_feeder = collect(keys(feeders))[1]

					if size(config.storages[prev_feeder].feeders)[1] == 1

						prev_unit::Int = config.storages[prev_feeder].feeders[1]
						if !(state.unit_active[prev_unit, event] > 0 && candidate.instructions[prev_unit, event] == 0)
							prev_unit_amount = state.unit_amounts[prev_unit, event]
						end
					end
				end

				alpha = tasks[instruction].alpha
				beta = tasks[instruction].beta

				if print_data
					@printf "Instruction: %d\n" instruction

					@printf "Feeders: "
					print(feeders)
					newline()
					for f in keys(feeders)
						@printf "%d: %.3f " f state.storage_amounts[f]
					end
					newline()

					@printf "Receivers: "
					print(receivers)
					newline()

					print(tasks)
					newline()
					
					@printf "Alpha: %f\n" alpha
					@printf "Beta: %f\n" beta
				end

				# Proceed to new task only if unit is empty 
				if unit_amount == 0

					#Iterate through subsequent instructions to determine maximum duration
					amount = 0.0
					task_duration = 0.0
					max_reached = false
					
					active = 0
					task_end::Int = event # from current event to final event point of task

					if prev_unit_amount > 0
						max_amount::Float64 = state.storage_amounts[prev_feeder] + prev_unit_amount
						while true

							task_duration += candidate.durations[task_end]
							if task_duration >= alpha 
								active = true
								amount = (task_duration - alpha) / beta 
								if amount > max_amount 
									amount = max_amount
									max_reached = true
								end
								if amount > unit_capacity
									amount = unit_capacity
									max_reached = true
								end
								if max_reached break end
							end
							task_end += 1
							if task_end >= params.no_events break end #If time horizon reached
							if candidate.instructions[unit, task_end] != 0 break end #If next instruction = 1
						end
					else

					while true #Continue until inner conditions break out of the loop

						task_duration += candidate.durations[task_end]
						if task_duration >= alpha 
							active = instruction
							amount = (task_duration - alpha) / beta 
							for (feeder, fraction) in feeders
								if fraction * amount > state.storage_amounts[feeder]
									amount = state.storage_amounts[feeder] / fraction
									max_reached = true
								end
							end
							if amount > unit_capacity
								amount = unit_capacity
								max_reached = true
							end
							if max_reached break end
						end

						task_end += 1

						if task_end >= params.no_events break end #If time horizon reached
						if candidate.instructions[unit, task_end] != 0 break end #If next instuction is a new one

					end #While 

					end #end if/else

					if active > 0
						state.unit_amounts[unit, event + 1] = amount

						# Flush from previous unit 
						if prev_unit_amount > 0
							if amount >= prev_unit_amount
								state.unit_amounts[prev_unit, event] = 0
								amount -= prev_unit_amount
							else
								state.unit_amounts[prev_unit, event] = prev_unit_amount - amount	
								amount = 0
							end
						end
						
						for (feeder, fraction) in feeders
							state.storage_amounts[feeder] -= fraction * amount
						end

						for i in event:task_end
							state.unit_active[unit, i] = instruction
						end

						if print_data @printf "AMOUNT TO BE PROCESSED: %.2f\n" amount end
					end

					if print_data newline() end

				end #if unit_amount == 0
			end
			# instruction handled

			if print_data @printf "\n" end
		end
	end	

	##### Final flush ### FLUSH all relevant feeder units into PRODUCT states #####
	
	for unit in 1:config.no_units
		flush(config, state, unit, params.no_events + 1, 1)
	end

	if print_data
		for prod in config.products
			@printf "Prod %d: %.3f  " prod state.storage_amounts[prod]
		end
		newline(2)
	end

	# Return profit

	result::Float64 = sum(config.prices.*(state.storage_amounts[config.products]))
	return result
end
