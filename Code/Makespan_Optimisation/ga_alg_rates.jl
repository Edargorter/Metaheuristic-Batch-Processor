####### METAHEURISTIC FILE ################
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

include("mbp_simulator.jl")

#Random seed based on number of milliseconds of current date
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 

### key=hfuncs Helping functions ###

# Round up to 1 if value < 0
function keep_positive(value::Float64) value < 0.0 ? 0.0 : value end

# Bit-flip
function bit_flip(bit::Int) bit == 0 ? 1 : 0 end

# Instruction change
function instr_change(unit::MBP_Unit) 
	instrs = [[v.first for v in collect(unit.tasks)]; 0]
	instrs[rand(1:size(instrs)[1])]
end

##### End of helping functions #####

### key=crossfuncs Crossover Functions ###

# Mutation on instruction array
function mutate_instructions(B::MBP_Program, config::MBP_Config, no_events::Int)
	unit::Int = rand(1:config.no_units)
	event::Int = rand(1:no_events)
	B.instructions[unit, event] = instr_change(config.units[unit])
end

# Mutation on duration array
function mutate_durations(B::MBP_Program, no_events::Int, delta::Float64, horizon::Float64)
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
		for i in 1:no_events B.durations[i] = keep_positive(B.durations[i] - diff) end
	end
end

### key=crossfuncs Crossover Functions ###

# Instruction Crossover
function instruction_crossover(instructions_a::Array{Int, 2}, instructions_b::Array{Int, 2}, c_point::Int)
	new_a = copy(instructions_a)
	new_b = copy(instructions_b)
	len = size(new_a)[2]
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
function crossover(A::MBP_Program, B::MBP_Program, c_point::Int, cross_instr::Bool)
	if cross_instr
		instr_a, instr_b = instruction_crossover(A.instructions, B.instructions, c_point)
	else
		instr_a, instr_b = copy(A.instructions), copy(B.instructions)
	end 

	ti_a, ti_b = time_crossover(A.durations, B.durations, c_point)

	MBP_Program(instr_a, ti_a), MBP_Program(instr_b, ti_b)
end

##### EVOLUTION OF CANDIDATE SOLUTIONS #####

### key=evolfunc Evolution Function ###
function evolve_chromosomes(config::MBP_Config, params::Params, candidates::Array{MBP_Program}, display_info::Bool=false)

	N::Int = params.population
	fitness::Array{Float64} = zeros(N)
	best_index::Int = 0
	best_fitness::Float64 = 0
	elite::Int = ceil(params.theta*N) # Number of elite (parents) to be picked

	if (N - elite) % 2 != 0 elite -= 1 end # Keep elite even (convenient for reproduction)

	mutation_rate::Float32 = params.mutation_rate 
	generations::Int = params.generations 

	instr_mu_no::Int = 0
	instr_cr_no::Int = 0

	instr_cross_rate::Float32 = params.instruction_theta
	instr_mutation_rate::Float32 = params.instruction_mutation

	instr_cr_decr::Float32 = instr_cross_rate / generations
	instr_mu_decr::Float32 = instr_mutation_rate / generations

	no_mutation::Int = 0

	# Generation loop
	for generation in 1:generations

		# Number of progeny to undergo mutation
		no_mutations = ceil(mutation_rate * (N - elite))

		instr_mu_no = ceil(instr_mutation_rate*(N - elite)) 
		instr_cr_no = ceil(instr_cross_rate*(N - elite))

		instr_cross_rate -= instr_cr_decr
		instr_mutation_rate -= instr_mu_decr

		# New random seed
		Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 

		for s in 1:N fitness[s] = get_fitness(config, params, candidates[s]) end

		if display_info
			newline()
			for i in 1:50
				print(candidates[i])
				newline()
			end
			print(fitness[1:50])
			newline()
			readline()
		end

		average_fitness::Float64 = sum(fitness)/N
		indices::Array{Int} = sortperm(fitness, rev=true)

		best_index = indices[1]
		best_fitness = fitness[best_index]

		#=
		to_write::String = "Generation: $(generation)\t ----- Average Fitness: $(average_fitness) \t----- Best: $(best_fitness)\n" 
		write(logfd, to_write)
		=#

		if display_info
			@printf "Generation: %d\t ----- Average Fitness : %.2f \t----- Best: %.2f\n" generation average_fitness best_fitness
		end

		### CROSSOVERS ###

		cr_instr::Bool = true

		for new in (elite + 1):2:N
			if instr_cr_no == 0.0
				cr_instr = false
			end
			i_a::Int, i_b::Int = indices[rand(1:elite)], indices[rand(1:elite)] # Random parents
			c_point::Int = rand(1:params.no_events)
			candidates[indices[new]], candidates[indices[new + 1]] = crossover(candidates[i_a], candidates[i_b], c_point, cr_instr)
		end
		
		### MUTATIONS ###

		index::Int = 0

		### Instructions 

		m_indices::Array{Int} = sample((elite + 1):N, instr_mu_no)
		for m_index in m_indices
			index = indices[m_index]
			mutate_instructions(candidates[index], config, params.no_events)
		end

		### Durations

		m_indices = sample((elite + 1):N, no_mutation)
		for m_index in m_indices
			index = indices[m_index]
			mutate_durations(candidates[index], params.no_events, params.delta, params.horizon)
		end

	end
	best_index, best_fitness #Return best candidate index and fitness
end
