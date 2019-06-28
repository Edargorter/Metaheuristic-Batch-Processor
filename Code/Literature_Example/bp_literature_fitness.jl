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
	unit_activated::Array{Int, 2} = zeros(config.no_units, params.no_events + 1)
	storage_amounts::Array{Float64} = zeros(config.no_storages)
	storage_amounts[1] = Inf
	storage_amounts[2] = Inf
	storage_amounts[3] = Inf

	# Default state
	state::BPS_State = BPS_State(unit_amounts, unit_activated, storage_amounts)	
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

	# Iterate through events
	for event in 1:params.no_events

		# Iterate through units
		for unit in 1:config.no_units

			# Unit parameters
			tasks::Dict{Int, Coefs} = config.units[unit].tasks
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
				@printf "DURATION: %.2f\n" duration
				@printf "STATUS: %d\n" active
			end

			# Instruction 0 (Continue task if one exists)
			if instruction == 0
				
				# Pass on values 
				if active > 0

					# Get feeding/receiving storages
					feeders = config.tasks[active].feeders
					receivers = config.tasks[active].receivers

					state.unit_amounts[unit, event + 1] = unit_amount

				elseif event > 1 && state.unit_active[unit, event - 1] == active
					for (receiver, fraction) in receivers
						recv_cap = config.storage_capacity[receiver]
						recv_amount = state.storage_amounts[receiver]

						if recv_cap - recv_amount < unit_amount * fraction
							flush[receiver] = recv_cap
						else
							flush[receiver] = unit_amount * fraction
						end
					end
					for (receiver, fraction) in receivers 
						unit_amount -= flush[receiver]
						state.storage_amounts[receiver] = flush[receiver]
					end
				end

			# Instruction 1 (Start new task if possible)
			elseif instruction in tasks

				# Get feeding/receiving storages
				feeders = config.tasks[instruction].feeders
				receivers = config.tasks[instruction].receivers
				
				alpha = tasks[instruction].alpha
				beta = tasks[instruction].beta
				flush::Array{Float64} = Array{undef, size(collect(receivers))[1]}

				# Flush contents from completed task if needed
				if event > 1 && state.unit_amounts[unit, event] > 0.0
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

				#Iterate through subsequent instructions to determine maximum duration
				amount::Float64 = 0.0
				task_duration = 0.0
				max_reached::Bool = false
				active = 0

				task_end::Int = event # from current event to final event point of task

				while true #Continue until inner conditions break out of the loop

					task_duration += candidate.durations[task_end]
					if task_duration >= alpha 
						active = instruction
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
						state.unit_active[unit, i] = instruction
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

	##### Final flush ### FLUSH all relevant feeder units into PRODUCT states #####
	
	for unit in config.no_units
		tasks = config.units[unit].tasks
				
		for prod in config.products
			if prod in tasks && state.unit_active[params.no_events] == config.prod_reactions[prod]
				unit_amount = state.unit_amounts[unit, params.no_events + 1]
				recv_capacity = state.storage_capacity[prod]
				recv_amount = state.storage_amounts[prod]
				
				if recv_capacity - recv_amount < unit_amount
					state.storage_amounts[prod] = recv_capacity
				else
					state.storage_amounts[prod] += unit_amount
				end

			end
		end

	end

	#= #### TEMPLATE FLUSH CODE #####

	unit_amount = state.unit_amounts[config.no_units, params.no_events + 1]
	recv_capacity = config.storage_capacity[config.product] 
	recv_amount = state.storage_amounts[config.product] 
	if recv_capacity - recv_amount < unit_amount
		state.storage_amounts[config.product] = recv_capacity
	else
		state.storage_amounts[config.product] += unit_amount
	end

	=#

	# Return profit
	sum(config.prices.*(state.storage_amounts[config.products]))
end
