##### Batch Processing first problem ##### GA #####
# - s1 -> Mixing - s2 -> Reaction - s3 -> Purification - s4 [Objective value]

using Printf

include("bp_motivating_structs.jl")
include("bp_motivating_functions.jl")
include("ga_alg_temp.jl")
include("bp_motivating_fitness_temp.jl")

#Seed
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

#### CONFIG PARAMETERS ####

config_filename = "config_motivating.txt"
config = read_config(config_filename)
parameters_filename = "parameters_1.txt"
params = read_parameters(parameters_filename)

##### TEST OPTIMAL SOLUTION FITNESS #####

instructions = [1 1 1 1;0 1 1 1;0 0 1 1]
durations = [4.665, 3.479, 2.427, 1.429]
#Test optimal solution
cand = BPS_Program(instructions, durations)
objective = get_fitness(config, params, cand, false)
@printf "\nMotivating example (Optimal): %.2f\n" objective

print("\n")

### RUN TESTS ###

no_params = 7
no_tests = 30
top_fitness = 0.0

@printf "TESTS: %d\n\n" no_tests

for p in 1:no_params

	#### METAHEURISTIC PARAMETERS ####
	parameters_filename = "parameters_$(p).txt"
	params = read_parameters(parameters_filename)
	@printf "Horizon: %.1f Events: %d Generations: %d \t--- " params.horizon params.no_events params.generations

	time_sum = 0.0
	top_fitness = 0.0

	for test in 1:no_tests
		Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

		##### GENERATE CANDIDATES #####
		cands = generate_pool(config, params)

		##### EVOLVE CHROMOSOMES #####
		seconds = @elapsed best, best_fitness = evolve_chromosomes(config, cands, params, false)
		time_sum += seconds

		if best_fitness > top_fitness top_fitness = best_fitness end
		
	end
	@printf "Total Time: %.6f Optimal Fitness: %.6f\n" time_sum top_fitness

end
