##### Batch Processing literature example #####

using Printf

include("bp_structs_2.jl")
include("bp_functions.jl")
include("mh_algs.jl")
include("bp_fitness_2.jl")

#Seed
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

##### TESTS #####

#### CONFIG PARAMETERS ####

no_units = 4
no_events 5
no_storages = 9
no_instructions = 5
products = [8, 9]

# Setup tasks 
tasks = []

feeders = Dict{Int, Float64}()
receivers = Dict{Int, Float64}()
feeders[1] = 1.0
receivers[4] = 1.0
push!(tasks, Task("Heating", feeders, receivers)

feeders = Dict{Int, Float64}()
receivers = Dict{Int, Float64}()
feeders[2] = 0.5
feeders[3] = 0.5
receivers[6] = 1.0
push!(tasks, Task("reaction 1", feeders, receivers))

feeders = Dict{Int, Float64}()
receivers = Dict{Int, Float64}()
feeders[4] = 0.4
feeders[6] = 0.6
receivers[8] = 0.4
receivers[5] = 0.6
push!(tasks, Task("reaction 2", feeders, receivers))

feeders = Dict{Int, Float64}()
receivers = Dict{Int, Float64}()
feeders[3] = 0.2
feeders[6] = 0.8
receivers[7] = 1.0
push!(tasks, Task("reaction 3", feeders, receivers))

feeders = Dict{Int, Float64}()
receivers = Dict{Int, Float64}()
feeders[7] = 1.0
receivers[5] = 0.1
receivers[9] = 0.9
push!(tasks, Task("still", feeders, receivers))

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

#Setup config
config = BPS_Config(no_units, no_storages, no_instructions, products, units, storage_capacity)

##### TESTS #####

no_params = 7
no_tests = 30

#Iterate through the parameters
for p in 1:no_params
	
	filename = "parameters_%d.txt" p

	#### METAHEURISTIC PARAMETERS ####
	params = read_parameters(filename)
	@printf "PARAMETERS %d\n" p

	for test in 1:30
		Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))
		
		#### CANDIDATE GENERATION ####
		cands = generate_pool(config, params)

		#### EVOLVE CHROMOSOMES ####
		#Get best with time

		@time best, best_fitness = evolve_chromosomes(config, cands, params)

		#print data
		@printf "Fitness: %.6f\n" best_fitness # PRINT INSTRUCTIONS DURATIONS AND FITNESS
		print_instructions(best, config, params)
		print_durations(best, config, params)
	end

end
