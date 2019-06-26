####### METAHEURISTIC #####################
####### Genetic Algorithm Functions #######


#= 
	
	Contents (Unique Search Strings):

	Section								Key (search)

	1) Helper functions:				hfuncs
	2) Crossover functions 				crossfuncs
	3) Mutation functions 				mutfuncs	
	4) Evolution function				evolfunc

=#


##### Imports #####

using Random
using Dates

include("bp_motivating_fitness.jl")

#Random seed based on number of milliseconds of current date
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 

### key=hfuncs Helping functions ###

# Round up to 1 if value < 0
function keep_positive(value::Float64) value < 0.0 ? 0.0 : value end

# Bit-flip
function bit_flip(bit::Int) bit == 0 ? 1 : 0 end

##### End of helping functions #####

### key=crossfuncs Crossover Functions ###

# Instruction Crossover
function instruction_crossover(instructions_a::Array{Int, 2}, instructions_b::Array{Int, 2}, c_point::Int)
	new_a = copy(instructions_a)
	new_b = copy(instructions_b)
	dims = size(new_a)
	len = dims[2]
	temp::Array{Int, 2} = new_a[:, c_point:len]
	new_a[:, c_point:len] = new_b[:, c_point:len]
	new_b[:, c_point:len] = temp
	new_a, new_b
end

# Durations crossover
function time_crossover(ti_a::Array{Float64}, ti_b::Array{Float64}, c_index::Int)
	new_ta = copy(ti_a)
	new_tb = copy(ti_b)
	size_arr::Int = length(new_ta)
	avg::Float64 = 0.50000 * (new_ta[c_index] + new_tb[c_index])
	diff_a::Float64 = (new_ta[c_index] - avg) / (size_arr - 1.0)
	diff_b::Float64 = (new_tb[c_index] - avg) / (size_arr - 1.0)
	for i in 1:size_arr
		new_ta[i] = keep_positive(new_ta[i] + diff_a)
		new_tb[i] = keep_positive(new_tb[i] + diff_b)
	end
	new_ta[c_index] = avg
	new_tb[c_index] = avg

	new_ta, new_tb
end

# Perform crossovers
function crossover(A::BPS_Program, B::BPS_Program, c_point::Int)
	instr_a, instr_b = instruction_crossover(A.instructions, B.instructions, c_point)
	ti_a, ti_b = time_crossover(A.durations, B.durations, c_point)
	BPS_Program(instr_a, ti_a), BPS_Program(instr_b, ti_b)
end

### key=mutfuncs Mutation Functions ###

# Mutation on instruction array
function mutate_instructions(B::BPS_Program, no_units::Int, no_events::Int)
	unit::Int = rand(1:no_units)
	event::Int = rand(1:no_events)
	B.instructions[unit, event] = bit_flip(B.instructions[unit, event])
end

# Mutation on duration array
function mutate_durations(B::BPS_Program, no_events::Int, delta::Float64, horizon::Float64)
	r::Float64 = 2.0*rand() - 1.0
	index::Int = rand(1:no_events)
	addition::Float64 = r*delta
	value::Float64 = keep_positive(B.durations[index] + addition)
	change::Float64 = addition / (no_events - 1.0)
	for i in 1:no_events B.durations[i] = keep_positive(B.durations[i] - change) end
	B.durations[index] = value

	# Check horizon
	sum_values::Float64 = sum(B.durations)
	if sum_values > horizon
		diff::Float64 = (sum_values - horizon) / no_events
		for i in 1:no_events B.durations[i] -= diff end
	end
end

##### EVOLUTION OF CANDIDATE SOLUTIONS #####

### key=evolfunc Evolution Function ###

function evolve_chromosomes(config::BPS_Config, candidates::Array{BPS_Program}, params::Params, display_info::Bool=true)
	N::Int = params.population
	fitness::Array{Float64} = zeros(N)
	best_index::Int = 0
	best_fitness::Float64 = 0
	elite::Int = ceil(params.theta*N) # Number of elite (parents) to be picked
	if (N - elite) % 2 != 0 elite -= 1 end # Keep elite even (convenient for reproduction)
	no_mutations::Int = ceil(params.mutation_rate*(N - elite)) # Number of progeny to undergo mutation

	# Generation loop
	for generation in 1:params.generations

		# New random seed
		Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 

		for s in 1:N fitness[s] = get_fitness(config, params, candidates[s]) end
		average_fitness::Float64 = sum(fitness)/N
		indices::Array{Int} = sortperm(fitness, rev=true)
		best_index = indices[1]
		best_fitness = fitness[best_index]

		if display_info
			@printf "Generation: %d\t ----- Average Fitness : %.2f \t----- Best: %.2f\n" generation average_fitness best_fitness
		end

		for new in (elite + 1):2:N
			i_a::Int, i_b::Int = indices[rand(1:elite)], indices[rand(1:elite)] # Random parents
			c_point::Int = rand(1:params.no_events)
			A::BPS_Program, B::BPS_Program = crossover(candidates[i_a], candidates[i_b], c_point)
			candidates[new] = A
			candidates[new + 1] = B
		end
		
		m_indices::Array{Int} = sample((elite + 1):N, no_mutations)
		for index in m_indices
			mutate_instructions(candidates[index], config.no_units, params.no_events)
			mutate_durations(candidates[index], params.no_events, params.delta, params.horizon)
		end

	end
	candidates[best_index], best_fitness
end
