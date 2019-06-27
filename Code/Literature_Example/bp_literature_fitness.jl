##### FITNESS FUNCTION (Literature Example) ##### Zachary Bowditch 2019 #####

using Printf
include("bp_literature_structs.jl")

### key=fitfunc FITNESS FUNCTION ###

# Evaluate fitness of a candidate Batch Processing Schedule (fitness metric = final state quantity)

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
			@printf "Storage %d: %.2f\n" i config.storage_capacity[i]
		end
	end

	# Initial declarations 

	recv_amount::Float64 = 0.0
	recv_cap::Float64 = 0.0

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

		# Iterate through units
		for unit in 1:config.no_units

			# in/outgoing units
			feeders = config.units[unit].feeders
			receiver = config.units[unit].receivers

			# Unit parameters
			reactions = config.units[unit].reactions
			unit_capacity = config.units[unit].capacity
			unit_amount = state.unit_amounts[unit, event]

			active = state.unit_active[unit, event]
			duration = candidate.durations[event]
			available = unit_capacity

			instruction = candidate.instructions[unit, event]	

			if print_data == true
				@printf "\n\n"
				@printf "EVENT: %d\n" event
				@printf "UNIT: %d\n" unit
				@printf "UNIT AMOUNT: %.2f\n" unit_amount
				@printf "INSTRUCTION: %d\n" instruction
				@printf "FEED: (%d) %.2f\n" feeder feeder_amount
				@printf "RECEIVER: %.2f\n" recv_amount
				@printf "DURATION: %.2f\n" duration
				@printf "ALPHA %.2f\n" alpha
				@printf "BETA %.2f\n" beta
				@printf "STATUS: %s\n" active == true ? "ACTIVE" : "INACTIVE"
			end

			# Instruction 0 (Continue task if one exists)
			if instruction == 0
				
				# Pass on values 
				if active == true
					state.unit_amounts[unit, event + 1] = unit_amount
				elseif event > 1 && state.unit_active[unit, event - 1] == true
					for (receiver, fraction) in receivers
						recv_cap = config.storage_capacity[receiver]
						recv_amount = state.storage_amounts[receiver]

						if recv_cap - recv_amount < unit_amount * fraction
							flush[receiver] = recv_cap
						else
							flush[receiver] = unit_amount * fraction
						end
					end
					for (receiever, fraction) in receivers 
						unit_amount -= flush[receiver]
						state.storage_amounts[receiver] = flush[receiver]
					end
				end

			# Instruction 1 (Start new task if possible)
			elseif instruction in reactions
				
				alpha = reactions[instruction].alpha
				beta = reactions[instruction].beta
				flush::Array{Float64} = Array{undef, config.units[unit].no_receivers}

				# Flush contents from completed task if needed
				if event > 1 && state.unit_amounts[unit, event] > 0.0
					for (receiver, fraction) in  receivers
						recv_cap = config.storage_capacity[receiver]
						recv_amount = state.storage_amounts[receiver]

						if recv_cap - recv_amount < unit_amount * fraction
							flush[receiver] = recv_cap
						else
							flush[receiver] = unit_amount * fraction
						end
					end
					for (receiever, fraction) in receivers
						unit_amount -= flush[receiver]
						state.storage_amounts[receiver] = flush[receiver]
					end
				end

				#Iterate through subsequent instructions to determine maximum duration
				amount::Float64 = 0.0
				task_duration = 0.0
				max_reached::Bool = false
				active = false

				task_end::Int = event # from current event to final event point of task

				while true #Continue until inner conditions break out of the loop

					task_duration += candidate.durations[task_end]
					if task_duration >= alpha 
						active = true
						amount = (task_duration - alpha) / beta 
						for (feeder, fraction) in feeders
							if fraction * amount > state.storage_amounts[feeder]
								amount = state.storage_amounts[feeder]
							end
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

				if active == true
					state.unit_amounts[unit, event + 1] = amount
					for (feeder, fraction) in feeders
						state.storage_amounts[feeder] -= fraction * amount
					end

					for i in event:task_end
						state.unit_active[unit, i] = true
					end

					if print_data == true
						@printf "AMOUNT TO BE PROCESSED: %.2f\n" amount
					end
				end

			end
			# instruction handled

			if print_data @printf "\n" end
		end
	end	

	# Final flush
			
	unit_amount = state.unit_amounts[config.no_units, params.no_events + 1]
	recv_capacity = config.storage_capacity[config.product] 
	recv_amount = state.storage_amounts[config.product] 
	if recv_capacity - recv_amount < unit_amount
		state.storage_amounts[config.product] = recv_capacity
	else
		state.storage_amounts[config.product] += unit_amount
	end

	# Return product amount 
	state.storage_amounts[config.product]
end
