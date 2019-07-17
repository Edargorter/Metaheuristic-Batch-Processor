##### Batch Processing literature example #####

using Printf

include("bp_literature_structs.jl")
include("bp_literature_functions.jl")
include("ga_alg.jl")
include("bp_literature_fitness.jl")

#Seed
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

function main_func()

	##### TESTS #####

	#### CONFIG PARAMETERS ####

	no_units = 4
	no_storages = 9
	no_instructions = 5
	products = [8, 9]
	prices = [10.0, 10.0]

	# Setup tasks 
	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[4] = 1.0
	push!(tasks, RTask("Heating", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 0.5
	feeders[3] = 0.5
	receivers[6] = 1.0
	push!(tasks, RTask("reaction 1", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[4] = 0.4
	feeders[6] = 0.6
	receivers[8] = 0.4
	receivers[5] = 0.6
	push!(tasks, RTask("reaction 2", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[3] = 0.2
	feeders[6] = 0.8
	receivers[7] = 1.0
	push!(tasks, RTask("reaction 3", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[7] = 1.0
	receivers[5] = 0.1
	receivers[9] = 0.9
	push!(tasks, RTask("still", feeders, receivers))

	#Setup units
	units = []

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[1] = Coefs(0.6667, 0.00667)

	unit_1 = Unit(100.0, unit_tasks)
	push!(units, unit_1)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[2] = Coefs(1.3333, 0.02664)
	unit_tasks[3] = Coefs(1.3333, 0.02664)
	unit_tasks[4] = Coefs(0.6667, 0.01332)

	unit_2 = Unit(50.0, unit_tasks)
	push!(units, unit_2)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[2] = Coefs(1.3333, 0.01665)
	unit_tasks[3] = Coefs(1.3333, 0.01665)
	unit_tasks[4] = Coefs(0.6667, 0.00833)

	unit_3 = Unit(50.0, unit_tasks)
	push!(units, unit_3)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[5] = Coefs(1.3342, 0.00666)

	unit_4 = Unit(200.0, unit_tasks)
	push!(units, unit_4)

	#Setup storages
	storage_capacity = [Inf, Inf, Inf, 100, 200, 150, 200, Inf, Inf]

	#Setup state reactions
	prod_reactions = Dict{Int, Int}()
	prod_reactions[8] = 3
	prod_reactions[9] = 5

	#Get sizes
	@printf "No. of tasks: %d\n" size(collect(tasks))[1]
	@printf "No. of units: %d\n" size(collect(units))[1]
	@printf "No. of storages: %d\n\n" size(collect(storage_capacity))[1]

	#Setup config
	config = BPS_Config(no_units, no_storages, no_instructions, products, prod_reactions, prices, units, tasks, storage_capacity)

	### RUN TESTS ###

	no_params = 9
	no_tests = 30
	top_fitness = 0.0

	@printf "TESTS: %d\n" no_tests
	newline()

	params = read_parameters("parameters_1.txt")
	cands = generate_pool(config, params)

	##### EVOLVE CHROMOSOMES #####
	seconds = @elapsed best, best_fitness = evolve_chromosomes(config, cands, params, true)

	newline()
	@printf "Best Candidate: \n"

	print(cands[best])
	newline()

	@printf "Fitness: %.6f\n" best_fitness

	#=

	for p in 1:no_params

		#### METAHEURISTIC PARAMETERS ####
		parameters_filename = "parameters_$(p).txt"
		params = read_parameters(parameters_filename)
		@printf "Horizon: %.1f Events: %d Generations: %d \t--- " params.horizon params.no_events params.generations

		time_sum = 0.0
		top_fitness = 0.0

		for test in 1:no_tests

			##### GENERATE CANDIDATES #####
			cands = generate_pool(config, params)

			##### EVOLVE CHROMOSOMES #####
			seconds = @elapsed best, best_fitness = evolve_chromosomes(config, cands, params, false)
			time_sum += seconds

			#print data
	#		print_instructions(best, config, params)
	#		print_durations(best, config, params)

			if best_fitness > top_fitness top_fitness = best_fitness end
			
		end
		@printf "Total Time: %.6f Optimal Fitness: %.6f\n" time_sum top_fitness

	end
	=#
end

main_func()
