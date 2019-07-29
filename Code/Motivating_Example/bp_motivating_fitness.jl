##### FITNESS FUNCTION (Motivating Example) #####

using Printf
include("bp_motivating_structs.jl")

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

#Flush unit contents
function flush(config::BPS_Config, state::BPS_State, unit::Int, event::Int, instruction::Int)	
	if instruction == 0 && state.unit_active[unit, event] return end

	unit_amount::Float64 = state.unit_amounts[unit, event]

	if unit_amount == 0 return end

	amount::Float64 = unit_amount

	# in/outgoing units

	receiver = config.units[unit].receiver
	recv_amount = state.storage_amounts[receiver]
	recv_capacity = config.storages[receiver].capacity

	if recv_capacity - recv_amount < unit_amount
		state.storage_amounts[receiver] = recv_capacity
		unit_amount -= (recv_capacity - recv_amount)
	else
		state.storage_amounts[receiver] += unit_amount
		unit_amount = 0.0
	end

	state.unit_amounts[unit, event] = unit_amount
end

# Evaluate fitness of a candidate Batch Processing Schedule (fitness metric = final state quantity)


### key=fitfunc FITNESS FUNCTION ###
function get_fitness(config::BPS_Config, params::Params, candidate::BPS_Program, print_data::Bool=false)
	# If sum of durations of candidate exceeds horizon, candidate is nullified 
	if sum(candidate.durations) > params.horizon return 0 end
	
	# Set initial state parameters
	unit_amounts::Array{Float64, 2} = zeros(config.no_units, params.no_events + 1)
	unit_activated::Array{Bool, 2} = zeros(config.no_units, params.no_events + 1)
	storage_amounts::Array{Float64} = zeros(config.no_storages)
	storage_amounts[1, 1] = Inf

	# Default state
	state::BPS_State = BPS_State(unit_amounts, unit_activated, storage_amounts)	
	task_duration::Float64 = 0.0 # Temp variable for task length in unit of time (e.g. hours) 

	if print_data == true
		@printf "\n\n"
		for i in 1:config.no_units
			@printf "Unit %d: %d %d %f %f %f\n" i config.units[i].feeder config.units[i].receiver config.units[i].alpha config.units[i].beta config.units[i].capacity
		end
		for i in 1:config.no_storages
			@printf "Storage %d: %.2f\n" i config.storages[i].capacity
		end
	end

	newline()
	print(config.storages)
	newline()

	# Initial declarations 

	feeder::Int = 0
	feeder_amount::Float64 = 0.0
	prev_unit::Int = 0
	prev_unit_amount::Float64 = 0.0
	receiver::Int = 0
	recv_amount::Float64 = 0.0
	recv_capacity::Float64 = 0.0

	# Unit parameters
	alpha::Float64 = 0.0
	beta::Float64 = 0.0
	unit_capacity::Float64 = 0.0
	unit_amount::Float64 = 0.0

	active::Bool = false
	duration::Float64 = 0.0
	available::Float64 = 0.0

	instruction::Int = 0

	# Iterate through events
	for event in 1:params.no_events

		@printf "=============== EVENT %d ===============" event
		newline(2)

		#=
		# Flush unit contents if possible
		if event > 1
			for unit in 1:config.no_units
				flush(config, state, unit, event, candidate.instructions[unit, event])
			end
		end
		=#
		for i in 1:config.no_storages
			@printf "%.2f " state.storage_amounts[i]
		end
		newline(2)

		for unit in 1:config.no_units
			for e in 1:params.no_events
				@printf "%.2f " state.unit_amounts[unit, e]
			end			
			newline()
		end
		newline()

		# Iterate through units
		for unit in config.no_units:-1:1

			# in/outgoing units
			feeder = config.units[unit].feeder
			feeder_amount = state.storage_amounts[feeder]

			receiver = config.units[unit].receiver
			recv_amount = state.storage_amounts[receiver]
			recv_capacity = config.storages[receiver].capacity

			prev_unit = config.storages[feeder].feeder_unit

			if prev_unit == 0
				prev_unit_amount = 0
			elseif state.unit_active[prev_unit, event] && candidate.instructions[prev_unit, event] == 0
				prev_unit_amount = 0
			else
				prev_unit_amount = state.unit_amounts[prev_unit, event]
			end

			# Unit parameters
			alpha = config.units[unit].alpha
			beta = config.units[unit].beta
			unit_capacity = config.units[unit].capacity
			unit_amount = state.unit_amounts[unit, event]

			active = state.unit_active[unit, event]
			duration = candidate.durations[event]
			available = unit_capacity

			instruction = candidate.instructions[unit, event]	

			if print_data
				newline()
				@printf "EVENT: %d\n" event
				@printf "UNIT: %d\n" unit
				@printf "UNIT AMOUNT: %.2f\n" unit_amount
				@printf "INSTRUCTION: %d\n" instruction
				@printf "FEED (%d): %.2f\n" feeder feeder_amount
				@printf "PREV UNIT FEED (%d): %.2f\n" prev_unit prev_unit_amount
				@printf "RECEIVER: %.2f\n" recv_amount
				@printf "DURATION: %.2f\n" duration
				@printf "ALPHA %.2f\n" alpha
				@printf "BETA %.2f\n" beta
				@printf "STATUS: %s\n" active == true ? "ACTIVE" : "INACTIVE"
			end

			# Instruction 0 (Continue task if one exists)
			if instruction == 0
				
				# Pass on values 

				state.unit_amounts[unit, event + 1] = unit_amount
				newline()
				@printf "Unit: %d Amount: %.3f" unit unit_amount 
				newline()

			# Instruction 1 (Start new task if possible)
			elseif instruction == 1

				if event > 1
					flush(config, state, unit, event, instruction)
					unit_amount = state.unit_amounts[unit, event]
				end

				# Only proceed to another task if unit is empty
				if true

					#Iterate through subsequent instructions to determine maximum duration

					amount::Float64 = 0.0
					max_amount::Float64 = feeder_amount + prev_unit_amount
					task_duration = 0.0
					max_reached::Bool = false
					active = false

					task_end::Int = event # from current event to final event point of task

					#Consume as much as possible given the event's duration
					while true

						task_duration += candidate.durations[task_end]
						if task_duration >= alpha 
							active = true
							amount = (task_duration - alpha) / beta 
							if amount > max_amount 
								amount = max_amount
								max_reached = true
							end
							if amount > unit_capacity - unit_amount 
								amount = unit_capacity - unit_amount 
								max_reached = true
							end
							if max_reached break end
						end
						task_end += 1
						if task_end >= params.no_events break end #If time horizon reached
						if candidate.instructions[unit, task_end] == 1 break end #If next instruction = 1
					end

					#Substract consumed volume from associated container and unit

					if active == true
						state.unit_amounts[unit, event + 1] = amount

						if print_data == true
							@printf "AMOUNT TO BE PROCESSED: %.2f\n" amount
						end

						if prev_unit != 0 
							if amount >= prev_unit_amount
								state.unit_amounts[prev_unit, event] = 0
								amount -= prev_unit_amount
							else
								state.unit_amounts[prev_unit, event] = prev_unit_amount - amount	
								amount = 0
							end
						end

						state.storage_amounts[feeder] = feeder_amount - amount

						for i in event:task_end
							state.unit_active[unit, i] = true
						end

					end

				end #if amount == 0

			end	 
			# instruction 1 handled
			if print_data @printf "\n" end
		end
	end	

	# Final flush
			
	for unit in 1:config.no_units
		flush(config, state, unit, params.no_events + 1, 1)
	end

	# Return product amount 
	state.storage_amounts[config.product]
end
