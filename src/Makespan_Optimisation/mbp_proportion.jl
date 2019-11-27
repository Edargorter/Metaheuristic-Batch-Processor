##### Batch Processing Case Study File #####

using Printf

### Data structs ###
include("mbp_structs.jl")
include("ga_structs.jl")

### Function packages ###
include("mbp_simulator.jl")
include("ga_alg_rates.jl") # Rate reduction GA (On instruction component)
#include("ga_alg.jl")
include("mbp_functions.jl")

#=

Storages:

1: Feed A
2: Feed B
3: Feed C
4: Hot A
5: Int AB
6: Int BC
7: Impure E
8: Product 1
9: Product 2

=#

function newline(n::Int=1) for i in 1:n @printf "\n" end end

function keep_zero(n::Float64)
	n < 0 ? 0 : n
end

#Get appropriate event point number based on horizon
function get_estimate(val::Float64, coefs::Array{Float64})
	trunc(Int, ceil(sum([(val ^ (i - 1))*coefs[i] for i in 1:length(coefs)])))
end

# Estimate the upper bound for the horizon of a system in order to produce 'demand'
function estimate_upper(config::MBP_Config, params::Params, demand_error::Float64, coefs::Array{Float64}, popul::Int)

	profit::Float64 = 0
	best_index::Int = 0
	horizon::Float64 = params.horizon
	no_events::Int = keep_two(get_estimate(horizon, coefs))
	params = Params(horizon, no_events, params.population, params.generations, params.theta, params.instruction_theta, params.mutation_rate, params.instruction_mutation, params.delta)
	cands::Array{MBP_Program} = []

	while true
		@printf "Finding upper bound ... Horizon: %.3f Events: %d\n" horizon no_events
		cands = generate_pool(config, params)
		best_index, best_error = evolve_chromosomes(config, params, cands, false)
		if best_error >= demand_error
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

	no_units = 4
	no_storages = 9
	no_instructions = 5
	products = [8, 9]
	prices = [10.0, 10.0]

	#### Setup tasks ####

	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[4] = 1.0
	push!(tasks, MBP_Task("Heating", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 0.5
	feeders[3] = 0.5
	receivers[6] = 1.0
	push!(tasks, MBP_Task("reaction 1", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[4] = 0.4
	feeders[6] = 0.6
	receivers[8] = 0.4
	receivers[5] = 0.6
	push!(tasks, MBP_Task("reaction 2", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[3] = 0.2
	feeders[5] = 0.8
	receivers[7] = 1.0
	push!(tasks, MBP_Task("reaction 3", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[7] = 1.0
	receivers[5] = 0.1
	receivers[9] = 0.9
	push!(tasks, MBP_Task("still", feeders, receivers))

	#### Setup storages ####	
	
	storages = []
	
	feeders = []
	receivers = [1]
	feed_A = MBP_Storage("Feed_A", Inf, feeders, receivers)
	push!(storages, feed_A)

	feeders = []
	receivers = [2]
	feed_B = MBP_Storage("Feed_B", Inf, feeders, receivers)
	push!(storages, feed_B)

	feeders = []
	receivers = [2, 4]
	feed_C = MBP_Storage("Feed_C", Inf, feeders, receivers)
	push!(storages, feed_C)

	feeders = [1]
	receivers = [3]
	hot_A = MBP_Storage("Hot A", 100, feeders, receivers)
	push!(storages, hot_A)

	feeders = [4]
	receivers = [3, 5]
	int_AB = MBP_Storage("Int AB", 200, feeders, receivers)
	push!(storages, int_AB)

	feeders = [3]
	receivers = [2]
	int_BC = MBP_Storage("Int BC", 150, feeders, receivers)
	push!(storages, int_BC)

	feeders = [4]
	receivers = [5]
	impure_E = MBP_Storage("Impure E", 200, feeders, receivers)
	push!(storages, impure_E)

	feeders = [3]
	receivers = []
	product_1 = MBP_Storage("Product 1", Inf, feeders, receivers)
	push!(storages, product_1)

	feeders = [5]
	receivers = []
	product_2 = MBP_Storage("Product 2", Inf, feeders, receivers)
	push!(storages, product_2)

	##### Reactions #####
	#=

	Mixing		: 1
	Reaction 1	: 2
	Reaction 2	: 3
	Reaction 3	: 4
	Seperation	: 5
	
	=#
	#####################

	#Setup units
	units = []

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[1] = MBP_Coefs(2/3, 1/150)

	unit_1 = MBP_Unit("Heater", 100.0, unit_tasks)
	push!(units, unit_1)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[2] = MBP_Coefs(4/3, 2/75)
	unit_tasks[3] = MBP_Coefs(4/3, 2/75)
	unit_tasks[4] = MBP_Coefs(2/3, 1/75)

	unit_2 = MBP_Unit("Reactor 1", 50.0, unit_tasks)
	push!(units, unit_2)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[2] = MBP_Coefs(4/3, 1/60)
	unit_tasks[3] = MBP_Coefs(4/3, 1/60)
	unit_tasks[4] = MBP_Coefs(2/3, 1/120)

	unit_3 = MBP_Unit("Reactor 2", 80.0, unit_tasks)
	push!(units, unit_3)

	unit_tasks = Dict{Int, MBP_Coefs}()
	unit_tasks[5] = MBP_Coefs(4/3, 1/150)

	unit_4 = MBP_Unit("Still", 200.0, unit_tasks)
	push!(units, unit_4)

	#Initial volumes
	initial_volumes = [Inf, Inf, Inf, 0, 0, 0, 0, 0, 0]

	config = MBP_Config(no_units, no_storages, no_instructions, products, prices, units, tasks, storages, initial_volumes)

	#### MAKESPAN OPTIMISATION ####

	#Lit. Example 2 -> profit/demand = 10 x sum(mu)
	demand_error = 0.0
	demand = 400

	#Regression coefficients  -->  coefs[1]*horizon^0 + coefs[2]*horizon^1
	coefs = [-2.9166666, 0.9583333] 

	pop_gen_coefs = [56.98198198, 0.00495495]

	#MH Parameters:

	no_events = 10  # Estimated using regression of Horizons against Event points from previous configurations
	population = 50000
	elite_pop = 750
	generations = 100
	theta = 0.1

	instr_theta = 0.1
	min_instr_theta = 0

	mutation = 0.8

	instr_mutation = 0.8
	min_instr_mut = 0

	delta = 0.125
	max_delta = 0.25

	params = Params(10.0, no_events, population, generations, theta, instr_theta, mutation, instr_mutation, delta)

	init_upper = 20.0

	init_lower = 0 #Lower bound for horizon

	#init_cands, init_upper = estimate_upper(config, params, demand_error, coefs, elite_pop) #Upper bound for horizon

	@printf "Upper bound: %.3f\n" init_upper
	newline()

	time_sum = 0.0
	best_horizon = init_upper
	top_horizon = Inf

	#Iterations 
	no_tests = 5
	trials = 10

	best_error = Inf
	best_index = 0
	mid = 0
	profit = Inf
	best_states = []

	#Time taken across all trials and test numbers 
	time_sum = 0.0

	epsilon = 0.05
	elite_pop = 500
	max_pop = 1000
	pop_change::Int = 500

	#Approx number of iterations
	iters = ceil(log(2, (init_upper - init_lower) / epsilon))

	#Approximate exponential increase factor 
	incr_factor = (max_pop / elite_pop) ^ (1 / iters)

	instr_cr_change = (instr_theta - min_instr_theta) / iters
	instr_mu_change = (instr_mutation - min_instr_mut) / iters 
	delta_change = (max_delta - delta) / iters 

	counter = 1

	######## TRIALS #########
	for trial in 1:trials

	generations = get_estimate(elite_pop + 0.0, pop_gen_coefs)

	upper = init_upper
	lower = init_lower

	instructions = Array{Float64}(undef, 0, 0)
	durations = Array{Float64}(undef, 0)

	trial = -Inf

	best_horizon = 0
	curr_best = -demand 
	states = []

	display_data = false
	trial_error = -Inf
	prev_trial_error::Float64 = -Inf
	prev_trial_pop::Int = 0

	dir_up::Bool = false
	repeats::Int = 0
	counter = 1

	time_sum = 0

	#Approximate exponential increase factor 
	incr_factor = (max_pop / elite_pop) ^ (1 / iters)

	#Proportional error 
	prop_error::Float64 = 0.5

	#### New horizon ####
	mid = lower + (upper - lower) * prop_error
	no_events = keep_two(get_estimate(mid, coefs))

	#### BISECTION SEARCH ####	

	while abs(upper - lower) > epsilon

		params::Params = Params(mid, no_events, elite_pop, generations, theta, instr_theta, mutation, instr_mutation, delta)
		curr_error = -Inf

		#@printf "Generating Cands ... \n"
		#cands::Array{MBP_Program} = generate_pool(config, params)
		#cands::Array{MBP_Program} = copy(init_cands)

		@printf "COUNTER = %d\n" counter 
		@printf "Population: %d Generations: %d instr_cr: %.3f instr_mu: %.3f delta: %.3f\n" elite_pop generations instr_theta instr_mutation delta
		@printf "Upper: %.7f Mid: %.7f Lower: %.7f --- Events: %d\n" upper mid lower no_events

		if display_data
			for i in 1:10
				print(cands[i])
				newline()
			end
		end

		for test in 1:no_tests

			cands::Array{MBP_Program} = generate_pool(config, params)
			#cands::Array{MBP_Program} = copy(init_cands)

			seconds = @elapsed best_index, best_error = evolve_chromosomes(config, params, cands, display_data)
			@printf "Best Error: %.3f\n" best_error 

			time_sum += seconds

			if best_error > curr_error 
				curr_error = best_error
				instructions = copy(cands[best_index].instructions)
				durations = copy(cands[best_index].durations)
				if best_error >= demand_error
					break
				end
			end

		end

		trial_error = curr_error

		#If horizon increased but error didn't improve
		if dir_up && trial_error <= prev_trial_error
			newline()
			@printf "Didn't improve. Repeating level.\n"
			prev_trial_pop = elite_pop
			elite_pop = trunc(Int, ceil(elite_pop * incr_factor))
			generations = get_estimate(elite_pop + 0.0, pop_gen_coefs) #Suited for elite_pop population
			newline()
			repeats += 1
			continue
		end

		if repeats > 0
			elite_pop = prev_trial_pop
			repeats = 0
		end

		#In the (rare) event all solutions have overshot horizons 
		if trial_error < -400
			continue
		end

		@printf "Trial error: %.3f Prev Trial error: %.3f in %.3f seconds. Horizon: %.3f \n" trial_error prev_trial_error time_sum mid

		##### Receive states array from fitness function #####

		print(instructions)
		newline()
		print(durations)
		newline()

		best_cand::MBP_Program = MBP_Program(instructions, durations)
		states = get_fitness(config, params, best_cand, false, true)
		print(states)

		newline(2)

		if trial_error < demand_error
			#dir_up = true
			lower = mid
		else 
			dir_up = false
			upper = mid
			best_horizon = mid
			if best_horizon < top_horizon
				top_horizon = best_horizon
			end
			@printf "Found. Horizon: %.3f\n" mid 	
		end

		#### Update of variable parameters ####

		elite_pop = trunc(Int, ceil(elite_pop * incr_factor))
		generations = get_estimate(elite_pop + 0.0, pop_gen_coefs) #Suited for elite_pop population

		instr_theta = keep_zero(instr_theta - instr_cr_change)
		instr_mutation = keep_zero(instr_mutation - instr_mu_change)

		delta += delta_change 

		prev_trial_error = trial_error 

		counter += 1

		#### New horizon ####
		prop_error = -(trial_error / demand)

		mid = lower + (upper - lower) * prop_error
		no_events = keep_two(get_estimate(mid, coefs))

	end #While

	max_pop += pop_change 

	if top_horizon == Inf
		@printf "No horizon found.\n"
	else
		@printf "Shortest horizon found: %.7f in %.3f seconds\n" top_horizon time_sum
	end

	end #Trials

end

main_func()
