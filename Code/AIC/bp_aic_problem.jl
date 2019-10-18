##### Batch Processing literature example #####

using Printf

include("bp_primary_structs.jl")
include("bp_primary_functions.jl")
include("ga_alg.jl")
include("bp_primary_fitness_improved.jl")

#Seed
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

function main_func()

	##### TESTS #####

	#### CONFIG PARAMETERS ####

	no_units = 4
	no_storages = 6
	no_instructions = 4
	no_tasks = 4
	products = [6]
	prices = [10.0]

	# Setup tasks 
	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[2] = 0.5
	receivers[3] = 0.5
	push!(tasks, RTask("reaction 1", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 1.0
	receivers[4] = 1.0
	push!(tasks, RTask("reaction 2", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[3] = 1.0
	receivers[5] = 1.0
	push!(tasks, RTask("reaction 3", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[4] = 0.5
	feeders[5] = 0.5
	receivers[6] = 1.0
	push!(tasks, RTask("reaction 4", feeders, receivers))


	##### Reactions #####
	#=

	Reaction 1	: 1
	Reaction 2	: 2
	Reaction 3	: 3
	Reaction 4	: 4
	
	=#
	#####################


	#Setup units
	units = []

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[1] = Coefs(5/3, 1/30)

	unit_1 = Unit("Heater", 40, unit_tasks)
	push!(units, unit_1)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[2] = Coefs(7/3, 1/12)

	unit_2 = Unit("Reactor 1", 20, unit_tasks)
	push!(units, unit_2)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[3] = Coefs(2/3, 1/15)

	unit_3 = Unit("Reactor 2", 5, unit_tasks)
	push!(units, unit_3)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[4] = Coefs(8/3, 1/120)

	unit_4 = Unit("Still", 40, unit_tasks)
	push!(units, unit_4)

	#### Setup storages ####
	storages = []
	
	feeders = []
	receivers = [1]
	state_1 = BPS_Storage("S1", Inf, feeders, receivers)
	push!(storages, state_1)

	feeders = [1]
	receivers = [2]
	state_2 = BPS_Storage("S2", 10, feeders, receivers)
	push!(storages, state_2)

	feeders = [1]
	receivers = [3]
	state_3 = BPS_Storage("S3", 15, feeders, receivers)
	push!(storages, state_3)

	feeders = [2]
	receivers = [4]
	state_4 = BPS_Storage("S4", 10, feeders, receivers)
	push!(storages, state_4)

	feeders = [3]
	receivers = [4]
	state_5 = BPS_Storage("S5", 15, feeders, receivers)
	push!(storages, state_5)

	feeders = [4]
	receivers = []
	state_6 = BPS_Storage("S6", Inf, feeders, receivers)
	push!(storages, state_6)

	#Initial volumes
	initial_volumes = [Inf, 0, 0, 0, 0, 0]

	config = BPS_Config(no_units, no_storages, no_instructions, products, prices, units, tasks, storages, initial_volumes)

	params = read_parameters("tmp_params.txt")
	
#=
	instructions = [1 1 1 1 1 1;
					0 2 0 0 0 2;
					0 3 3 3 3 0;
					0 0 0 0 0 4]

	durations = [3 1 1 1 1 3]

	candidate = BPS_Program(instructions, durations)

	fitness = get_fitness(config, params, candidate)
	@printf "Fitness: %.3f\n" fitness
=#
	
	cands = generate_pool(config, params)

	best_index, best_fitness = evolve_chromosomes(config, cands, params)

	@printf "Best Fitness: %.3f\n" best_fitness
	newline()
	print(cands[best_index])
	newline()

##########################  TESTS  ############################### 

	#=

	no_params = 9
	no_tests = 5

	### RUN TESTS ###

	parameters_filename = "test_params.txt"

	@printf "TESTS: %d\n" no_tests
	newline()
	
	### GRID SEARCH ###

	thetas = 0:0.1:1.0
	mutations = 0:0.1:1.0
	deltas = 0:0.025:1.0

	# Metaheuristic parameters 

	overall_top_fitness = 0

	#Keep track of best combination of metaheuristic parameters
	best_theta = 0
	best_mutation = 0
	best_delta = 0

	combinations = size(deltas)[1] * size(mutations)[1] * size(deltas)[1]
	comb = 0

	for t in thetas
	for m in mutations
	for d in deltas
	
	for p in 1:no_params

		#logfile = open("log_$(p).txt", "a")

		#### METAHEURISTIC PARAMETERS ####
		#parameters_filename = "parameters_$(p).txt"
		param_file = read_parameters(parameters_filename)

		params = Params(params_file.horizon, params_file.no_events, params_file.population, params_file.generations, t, m, d)
		
		#Temporary instructions / duration arrays
		#instr_arr::Array{Int, 2} = zeros(config.no_units, params.no_events)	
		#durat_arr::Array{Float64} = zeros(params.no_events)

		#@printf "Horizon: %.1f Events: %d Generations: %d Population: %d \t--- " params.horizon params.no_events params.generations params.population

		time_sum = 0.0
		top_fitness = 0.0

		for test in 1:no_tests

			#### Test No. ####
			#write(logfile, "Test: $(test)\n")

			##### GENERATE CANDIDATES #####
			cands = generate_pool(config, params)

			##### EVOLVE CHROMOSOMES #####
			seconds = @elapsed best_index, best_fitness = evolve_chromosomes(logfile, config, cands, params, false)
			#time_sum += seconds

			if best_fitness > top_fitness
				top_fitness = best_fitness
				#instr_arr = copy(cands[best_index].instructions)
				#durat_arr = copy(cands[best_index].durations)
			end

		end

		if top_fitness > overall_top_fitness
			overall_top_fitness = top_fitness
			best_theta = t
			best_mutation = m
			best_delta = d
		end

		#@printf "Total Time: %.6f Optimal Fitness: %.6f " time_sum top_fitness
		#print(instr_arr)
		#print(durat_arr)
		#newline()

		#close(logfile)

	end

	comb += 1

	@printf "[%d / %d] Theta: %.2f Mutation: %.2f Delta: %.3f Best_t: %.2f Best_m: %.2f Best_d: %.3f \n" comb, combinations t, m, d, best_theta, best_mutation, best_delta
	
	end
	end
	end

=#

end

main_func()
