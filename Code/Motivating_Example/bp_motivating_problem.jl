##### Batch Processing first problem ##### GA #####
# - s1 -> Mixing - s2 -> Reaction - s3 -> Purification - s4 [Objective value]

using Printf

include("bp_motivating_structs.jl")
include("bp_motivating_functions.jl")
include("mh_algs.jl")
include("bp_motivating_fitness.jl")

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

for p in 1:no_params

	#### METAHEURISTIC PARAMETERS ####
	parameters_filename = "parameters_$(p).txt"
	params = read_parameters(parameters_filename)
	@printf "PARAMETERS %d\n" p

	for test in 1:no_tests
		Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

		##### GENERATE CANDIDATES #####
		cands = generate_pool(config, params)

		##### EVOLVE CHROMOSOMES #####
		@time best, best_fitness = evolve_chromosomes(config, cands, params)

		#print data
		@printf "Fitness: %.6f" best_fitness
		print_instructions(best, config, params)
		print_durations(best, config, params)
	end
	@printf "\n"

end
