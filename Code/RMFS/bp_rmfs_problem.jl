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

	no_units = 6
	no_storages = 6
	no_tasks = 4
	no_instructions = no_tasks
	products = [6]
	prices = [2.0]

	# Setup tasks 
	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[3] = 1.0
	push!(tasks, RTask("Reaction", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 0.5
	feeders[3] = 0.5
	receivers[4] = 1.0
	push!(tasks, RTask("Mixing", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[4] = 1.0
	receivers[5] = 1.0
	push!(tasks, RTask("Filtering", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[5] = 1.0
	feeders[6] = 1.0
	receivers[6] = 1.0
	push!(tasks, RTask("Stripping", feeders, receivers))

	##### Reactions #####
	#=

	Reaction	: 1
	Mixing		: 2
	Flitering	: 3
	Stripping 	: 4
	
	=#
	#####################

	var = 1/3

	#Setup units
	units = []

	unit_tasks = Dict{Int, Coefs}()
	alpha, beta = get_duration_parameters(var, 26.0, 20.0)
	unit_tasks[1] = Coefs(alpha, beta)

	reactor = Unit("Reactor", 20, unit_tasks)
	push!(units, reactor)

	unit_tasks = Dict{Int, Coefs}()
	alpha, beta = get_duration_parameters(var, 4.0, 20.0)
	unit_tasks[2] = Coefs(alpha, beta)

	mixer_1 = Unit("Mixer 1", 20, unit_tasks)
	push!(units, mixer_1)


	unit_tasks = Dict{Int, Coefs}()
	alpha, beta = get_duration_parameters(var, 4.0, 20.0)
	unit_tasks[2] = Coefs(alpha, beta)

	mixer_2 = Unit("Mixer 1", 20, unit_tasks)
	push!(units, mixer_2)


	unit_tasks = Dict{Int, Coefs}()
	alpha, beta = get_duration_parameters(var, 6.0, 20.0)
	unit_tasks[3] = Coefs(alpha, beta)

	filter = Unit("Filter", 20, unit_tasks)
	push!(units, filter)


	unit_tasks = Dict{Int, Coefs}()
	alpha, beta = get_duration_parameters(var, 8.0, 20.0)
	unit_tasks[4] = Coefs(alpha, beta)

	strip_tank_1 = Unit("Strip Tank 1", 20, unit_tasks)
	push!(units, strip_tank_1)


	unit_tasks = Dict{Int, Coefs}()
	alpha, beta = get_duration_parameters(var, 8.0, 20.0)
	unit_tasks[4] = Coefs(alpha, beta)

	strip_tank_2 = Unit("Strip Tank 2", 20, unit_tasks)
	push!(units, strip_tank_2)

	#### Setup storages ####
	storages = []
	
	feeders = []
	receivers = [1]
	feed = BPS_Storage("Feed", Inf, feeders, receivers)
	push!(storages, feed)

	feeders = []
	receivers = [2]
	add_1 = BPS_Storage("Add 1", Inf, feeders, receivers)
	push!(storages, add_1)

	feeders = [1]
	receivers = [2]
	r_prod = BPS_Storage("R Prod", 100, feeders, receivers)
	push!(storages, r_prod)

	feeders = [2]
	receivers = [3]
	blend = BPS_Storage("Blend", 100, feeders, receivers)
	push!(storages, blend)

	feeders = [3]
	receivers = [4]
	filt = BPS_Storage("Filt", 100, feeders, receivers)
	push!(storages, filt)

	feeders = [4]
	receivers = []
	prod = BPS_Storage("Prod", Inf, feeders, receivers)
	push!(storages, prod)

	#Initial volumes
	initial_volumes = [Inf, Inf, 0, 0, 0, 0]

	config = BPS_Config(no_units, no_storages, no_instructions, products, prices, units, tasks, storages, initial_volumes)

	params = read_parameters("tmp_params.txt")

	cands = generate_pool(config, params)

	best_index, best_fitness = evolve_chromosomes(config, cands, params)

	@printf "Best Fitness: %.3f\n" best_fitness
	fitness = get_fitness(config, params, cands[best_index], true)
	@printf "Fitness: %.3f\n" fitness
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
