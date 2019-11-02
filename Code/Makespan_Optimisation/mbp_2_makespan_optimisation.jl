##### Batch Processing Case Study File #####

using Printf

### Data structs ###
include("mbp_structs.jl")
include("ga_structs.jl")

### Function packages ###
include("mbp_2_simulator.jl")
#include("ga_2_alg_rates.jl") # Rate reduction GA (On instruction component)
include("ga_2_alg.jl")
include("mbp_functions.jl")

#=

Storages:

1: S1
2: S2
3: S3
4: S4

=#

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

#Get appropriate event point number based on horizon
function get_estimate(val::Float64, coefs::Array{Float64})
	trunc(Int, ceil(sum([(val ^ (i - 1))*coefs[i] for i in 1:length(coefs)])))
end

# Estimate the upper bound for the horizon of a system in order to produce 'demand'
function estimate_upper(config::MBP_Config, params::Params, demand::Float64, coefs::Array{Float64}, popul::Int)

	profit::Float64 = 0
	best_index::Int = 0
	horizon::Float64 = params.horizon
	no_events::Int = keep_two(get_estimate(horizon, coefs))
	params = Params(horizon, no_events, params.population, params.generations, params.theta, params.instruction_theta, params.mutation_rate, params.instruction_mutation, params.delta)
	cands::Array{MBP_Program} = []

	while true
		@printf "Finding upper bound ... Horizon: %.3f Events: %d\n" horizon no_events
		cands = generate_pool(config, params)
		best_index, best_demand = evolve_chromosomes(config, params, cands, false)
		if best >= demand
			break 
		end
		horizon *= 2.0
		no_events = keep_two(get_estimate(horizon, coefs))
		params = Params(horizon, no_events, params.population, params.generations, params.theta, params.instruction_theta, params.mutation_rate, params.instruction_mutation, params.delta)
	end	

	fitness::Array{Float64} = Array{Float64}(undef, params.population)
	for i in 1:params.population
		fitness[i] = get_fitness(config, params, cands[i])	
	end
	indices::Array{Int} = sortperm(fitness, rev=true)

	cands[indices[1:popul]], horizon
end

function main_func()

	##### TESTS #####

	#### CONFIG PARAMETERS ####

	no_units = 5
	no_storages = 4
	no_instructions = 3
	products = [4]
	prices = [1.0]

	#### Setup tasks ####

	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[2] = 1.0
	push!(tasks, MBP_Task("Task 1", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 1.0
	receivers[3] = 1.0
	push!(tasks, MBP_Task("Task 2", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[3] = 1.0
	receivers[4] = 1.0
	push!(tasks, MBP_Task("Task 3", feeders, receivers))


	#### Setup storages ####	

	
	storages = []
	
	feeders = []
	receivers = [1]
	s1 = MBP_Storage("S1", Inf, feeders, receivers)
	push!(storages, s1)

	feeders = [1]
	receivers = [2]
	s2 = MBP_Storage("S2", 200.0, feeders, receivers)
	push!(storages, s1)

	feeders = [2]
	receivers = [3]
	s3 = MBP_Storage("S3", 250.0, feeders, receivers)
	push!(storages, s1)

	feeders = [3]
	receivers = [4]
	s4 = MBP_Storage("S4", Inf, feeders, receivers)
	push!(storages, s1)


	#### Setup units ####


	units = []

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[1] = MBP_Coefs(4/3, 2/150)

	unit_1 = MBP_Unit("Unit 1", 100.0, unit_tasks)
	push!(units, unit_1)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[1] = MBP_Coefs(4/3, 2/150)

	unit_2 = MBP_Unit("Unit 2", 150.0, unit_tasks)
	push!(units, unit_2)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[2] = MBP_Coefs(1.0, 1/200)

	unit_3 = MBP_Unit("Unit 3", 200.0, unit_tasks)
	push!(units, unit_3)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[3] = MBP_Coefs(2/3, 2/450)

	unit_4 = MBP_Unit("Unit 4", 150.0, unit_tasks)
	push!(units, unit_4)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[3] = MBP_Coefs(2/3, 2/450)

	unit_5 = MBP_Unit("Unit 5", 150.0, unit_tasks)
	push!(units, unit_5)


	#Initial volumes
	initial_volumes = [Inf, 0.0, 0.0, 0.0]

	config = MBP_Config(no_units, no_storages, no_instructions, products, prices, units, tasks, storages, initial_volumes)

	#### MAKESPAN OPTIMISATION ####

	demand = 2000

	#Regression coefficients  -->  coefs[1]*horizon^0 + coefs[2]*horizon^1
	coefs = [-2.9166666, 0.9583333] 

	pop_gen_coefs = [56.98198198, 0.00495495]

	#MH Parameters:

	no_events = 10  # Estimated using regression of Horizons against Event points from previous configurations
	population = 1000
	elite_pop = 100
	generations = 50
	theta = 0.1
	instruction_theta = 0.1
	mutation = 0.8
	instruction_mutation = 0.8
	delta = 0.125

	#params = Params(20.0, no_events, population, generations, theta, instruction_theta, mutation, instruction_mutation, delta)

	init_upper = 30.0

	init_lower = 0 #Lower bound for horizon

	#init_cands, init_upper = estimate_upper(config, params, demand, coefs, elite_pop) #Upper bound for horizon

	@printf "Upper bound: %.3f\n" init_upper
	newline()

	time_sum = 0.0
	best_horizon = init_upper
	top_horizon = init_upper

	#Iterations 
	no_tests = 5
	trials = 1

	trial_profit = 0
	best_profit = 0
	best_index = 0
	mid = 0
	profit = Inf
	best_states = []

	#Time taken across all trials and test numbers 
	time_sum = 0.0

	epsilon = 0.1
	elite_pop = 50
	max_pop = 2000

	#Approximate exponential increase factor 
	incr_factor = (max_pop / elite_pop) ^ (1 / ceil(log(2, (init_upper - init_lower) / epsilon)))

	counter = 1

	######## TRIALS #########
	for trial in 1:trials

	generations = get_estimate(elite_pop + 0.0, pop_gen_coefs)

	upper = init_upper
	lower = init_lower

	instructions = Array{Float64}(undef, 0, 0)
	durations = Array{Float64}(undef, 0)

	best_horizon = 0
	states = []

	display_data = false

	while abs(upper - lower) > epsilon

		#### New horizon ####
		mid = lower + (upper - lower) / 2

		no_events = keep_two(get_estimate(mid, coefs))

		params::Params = Params(mid, no_events, elite_pop, generations, theta, instruction_theta, mutation, instruction_mutation, delta)
		trial_profit = 0

		#@printf "Generating Cands ... \n"
		cands::Array{MBP_Program} = generate_pool(config, params)

		@printf "COUNTER = %d\n" counter 
		@printf "Population: %d Generations: %d\n" elite_pop generations 
		@printf "Upper: %.7f Mid: %.7f Lower: %.7f\n" upper mid lower

		if display_data
			for i in 1:10
				print(cands[i])
				newline()
			end
		end

		for test in 1:no_tests

			#cands::Array{MBP_Program} = generate_pool(config, params)

			seconds = @elapsed best_index, best_profit = evolve_chromosomes(config, params, cands, display_data)

			time_sum += seconds

			if best_profit > trial_profit
				trial_profit = best_profit 
				instructions = copy(cands[best_index].instructions)
				durations = copy(cands[best_index].durations)
			end
		end

		@printf "Best profit %.3f in %.3f seconds. Horizon: %.3f \n" trial_profit time_sum mid

		##### Receive states array from fitness function #####

		print(instructions)
		newline()
		print(durations)
		newline()

		best_cand::MBP_Program = MBP_Program(instructions, durations)
		states = get_fitness(config, params, best_cand, false, true)
		print(states)

		newline(2)

		if trial_profit < demand
			lower = mid
		else 
			upper = mid
			best_horizon = mid
			if best_horizon < top_horizon
				top_horizon = best_horizon
			end
			@printf "Found. Horizon: %.3f\n" mid 	
		end

		elite_pop = trunc(Int, ceil(elite_pop * incr_factor))
		generations = get_estimate(elite_pop + 0.0, pop_gen_coefs) #Suited for elite_pop population

		counter += 1

	end #While

	end #Trials

	@printf "Shortest horizon found: %.7f in %.3f seconds\n" top_horizon time_sum

end

main_func()
