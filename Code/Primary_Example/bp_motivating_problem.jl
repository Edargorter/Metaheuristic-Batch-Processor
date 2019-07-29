##### Batch Processing literature example #####

using Printf

include("bp_primary_structs.jl")
include("bp_primary_functions.jl")
include("ga_alg.jl")
include("bp_primary_fitness.jl")

#Seed
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

function main_func()

	##### TESTS #####

	#### CONFIG PARAMETERS ####

	no_units = 3
	no_storages = 4
	no_instructions = 1
	products = [4]
	prices = [1.0]

	# Setup tasks 
	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[2] = 1.0
	push!(tasks, RTask("Mixing", feeders, receivers))


	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 1.0
	receivers[3] = 1.0
	push!(tasks, RTask("Reaction", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[3] = 1.0
	receivers[4] = 1.0
	push!(tasks, RTask("Purification", feeders, receivers))

	#Setup Units

	units = []

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[1] = Coefs(3.0, 0.03)
	unit_1 = Unit("Unit 1", 100.0, unit_tasks)
	push!(units, unit_1)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[1] = Coefs(2.0, 0.0267)
	unit_2 = Unit("Unit 2", 75.0, unit_tasks)
	push!(units, unit_2)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[1] = Coefs(1.0, 0.02)
	unit_3 = Unit("Unit 3", 50.0, unit_tasks)
	push!(units, unit_3)

	#Setup storages

	storage_capacity = [Inf, 100.0, 100.0, Inf]

	#Initial volumes
	initial_volumes = [Inf, 0.0, 0.0, 0.0]

	config = BPS_Config(no_units, no_storages, no_instructions, products, prices, units, tasks, storage_capacity, initial_volumes)	

	params = read_parameters("motiv_parameters.txt")

	##### Reactions #####
	#=

	Mixing		
	Reaction
	Purification	
	
	=#
	#####################

	instructions = [1 1 1 1;
					0 1 1 1;
					0 0 1 1]

	durations = [4.665, 3.479, 2.427, 1.429]

	@printf "Size of instructions: "
	print(size(instructions))
	newline()

	@printf "Size of durations: "
	print(size(durations))
	newline()

	bps_program = BPS_Program(instructions, durations)

	fitness = get_fitness(config, params, bps_program, true)
	@printf "Fitness: %.6f\n" fitness
	newline()

	#=

	# Generate random candidate solutions
	cands = generate_pool(config, params)

	##### EVOLVE CHROMOSOMES #####
	seconds = @elapsed best, best_fitness = evolve_chromosomes(config, cands, params, true)

	newline()
	@printf "Best Candidate: \n"

	print(cands[best])
	newline()

	@printf "Fitness: %.6f\n" best_fitness

	cal_fitness = get_fitness(config, params, cands[best], true)
	@printf "Calculated Fitness: %.6f\n" cal_fitness

	=#

	#=

	no_params = 9
	no_tests = 30
	top_fitness = 0.0

	### RUN TESTS ###

	@printf "TESTS: %d\n" no_tests
	newline()

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
