####### METAHEURISTIC #####################
####### LITERATURE EXAMPLE ################

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

include("bp_primary_fitness_improved.jl")

#Random seed based on number of milliseconds of current date
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 
rng = MersenneTwister(Dates.value(convert(Dates.Millisecond, Dates.now())))

### key=hfuncs Helping functions ###

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

# Round up to 0 if value < 0
function keep_positive(value::Float64) value < 0.0 ? 0.0 : value end

# Round up to 1 if value < 1
function keep_one(value::Int) value < 1 ? 1 : value end

# Bit-flip
function bit_flip(bit::Int) bit == 0 ? 1 : 0 end

# Instruction change
function instr_change(unit::Unit) 
	instrs = [[v.first for v in collect(unit.tasks)]; 0]
	instrs[rand(1:size(instrs)[1])]
end

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
	avg::Float64 = 0.5 * (new_ta[c_index] + new_tb[c_index])
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
function mutate_instructions(B::BPS_Program, config::BPS_Config, no_events::Int)
	unit::Int = rand(1:config.no_units)
	event::Int = rand(1:no_events)
	B.instructions[unit, event] = instr_change(config.units[unit])
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
		for i in 1:no_events B.durations[i] = keep_positive(B.durations[i] - diff) end
	end
end

##### EVOLUTION OF CANDIDATE SOLUTIONS #####

### key=evolfunc Evolution Function ###

#Print GA progression
function display_data(seconds::Float32, horizon::Float64, no_units::Int, no_events::Int, height::Int, width::Int, objective::Float64, candidate::BPS_Program, generations, best::Array{Float64}, average::Array{Float64})

	#Colours
	green::String = "\033[0;32m"
	yellow::String = "\033[1;33m"
	red::String = "\033[0;31m"
	lblue::String = "\033[1;34m"
	white::String = "\033[1;37m"

	interval::Int = trunc(Int, height / 7)
	disp_array::Array{String, 2} = fill(" ", (height, generations))
	scale = height / objective
	graph_offset::Int = 1
	offset::Int = 15

	@printf "\n"

	#Load display array
	for i in 1:size(best)[1]
		disp_array[keep_one(trunc(Int, height - best[i] * scale)), i] = "x"
		disp_array[keep_one(trunc(Int, height - average[i] * scale)), i] = "-"
	end

	print_unit_height::Int = trunc(Int, height / 2)
	unit::Int = 1

	#Print array 
	for r in 1:height
		for i in 1:graph_offset @printf " " end

		if r % interval == 0
			@printf "%.1f" (objective - r*interval)
		end
		@printf "\t- "
		for c in 1:generations 
			if disp_array[r, c] == "x"
				print(green)
				@printf "%s " disp_array[r, c] 
				print(white)
			elseif disp_array[r, c] == "-"
				print(yellow)
				@printf "%s " disp_array[r, c] 
				print(white)
			else
				@printf "%s " disp_array[r, c] 
			end
		end

		#Print other info
		if r == print_unit_height - 11
			for i in 1:offset @printf " " end
			@printf "Horizon: %.1f Events: %d" horizon no_events
		elseif r == print_unit_height - 9
			for i in 1:offset @printf " " end
			@printf "Objective: %.2f" objective
		elseif r == print_unit_height - 7
			for i in 1:offset @printf " " end
			@printf "Key:"
		elseif r == print_unit_height - 5
			for i in 1:offset @printf " " end
			print(green)
			@printf "x"
			print(white)
			@printf " = Best fitness"
		elseif r == print_unit_height - 4
			for i in 1:offset @printf " " end
			print(yellow)
			@printf "-"
			print(white)
			@printf " = Average fitness"
		elseif r == print_unit_height - 1
			for i in 1:offset @printf " " end
			@printf "INSTRUCTION CHROMOSOME:"
		elseif r > print_unit_height && unit <= no_units 
			for i in 1:offset @printf " " end
			for event in 1:no_events
				@printf "%d  " candidate.instructions[unit, event]
			end
			unit += 1
		elseif r == print_unit_height + no_units + 2
			for i in 1:offset @printf " " end
			@printf "TIME CHROMOSOME:"
		elseif r == print_unit_height + no_units + 4
			for i in 1:offset @printf " " end
			@printf "[ "
			for event in 1:no_events
				@printf "%.2f " candidate.durations[event]
			end
			@printf "]"
		elseif r == print_unit_height + no_units + 6
			for i in 1:offset @printf " " end
			print(red)
			@printf "Top fitness: "
			print(white)
			@printf "%.2f" best[end]
		elseif r == print_unit_height + no_units + 7
			for i in 1:offset @printf " " end
			@printf "Error: %.2f%%" 100*(1.0 - best[end]/objective)
		elseif r == print_unit_height + no_units + 10
			for i in 1:offset @printf " " end
			@printf "Delay (seconds): %.1f" seconds 
		end

		@printf "\n"
	end

	#Print x-axis
	for i in 1:graph_offset @printf " " end
	@printf "\t -"

	for i in 1:generations @printf "--" end

	@printf "\n"
	for i in 1:graph_offset @printf " " end
	str::String = "Generations ---> $(generations)"
	len::Int = trunc(Int, (2 * generations)/2)
	for i in 1:len @printf " " end
	@printf "%s" str
	for i in 1:offset @printf "   " end
end

function evolve_chromosomes(config::BPS_Config, params::Params, candidates::Array{BPS_Program}, display_info::Bool=false)
	N::Int = params.population
	fitness::Array{Float64} = zeros(N)
	best_index::Int = 0
	best_fitness::Float64 = 0

	bests::Array{Float64} = []
	avgs::Array{Float64} = []

	elite::Int = ceil(params.theta*N) # Number of elite (parents) to be picked
	if (N - elite) % 2 != 0 elite -= 1 end # Keep elite even (convenient for reproduction)
	no_mutations::Int = ceil(params.mutation_rate*(N - elite)) # Number of progeny to undergo mutation

	# Generation loop
	for generation in 1:params.generations

		# New random seed
		Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 
		rng = MersenneTwister(Dates.value(convert(Dates.Millisecond, Dates.now())))

		for s in 1:N fitness[s] = get_fitness(config, params, candidates[s], false) end

		average_fitness::Float64 = round(sum(fitness)/N, digits=4)

		indices::Array{Int} = sortperm(fitness, rev=true)
		best_index = indices[1]
		best_fitness = round(fitness[best_index], digits=4)

		### Add to best / average fitness arrays 
		push!(bests, best_fitness)
		push!(avgs, average_fitness)

		#=
		to_write::String = "Generation: $(generation)\t ----- Average Fitness: $(average_fitness) \t----- Best: $(best_fitness)\n" 
		write(logfd, to_write)
		=#

		for new in (elite + 1):2:N
			i_a::Int, i_b::Int = indices[rand(1:elite)], indices[rand(1:elite)] # Random parents
			c_point::Int = rand(1:params.no_events)
			candidates[indices[new]], candidates[indices[new + 1]] = crossover(candidates[i_a], candidates[i_b], c_point)
		end
		
		m_indices::Array{Int} = sample((elite + 1):N, no_mutations)
		for m_index in m_indices
			index::Int = indices[m_index]	
			mutate_instructions(candidates[index], config, params.no_events)
			mutate_durations(candidates[index], params.no_events, params.delta, params.horizon)
		end

		height::Int = 48
		width::Int = 100
		seconds::Float32 = 1.5
		objective::Float64 = 1498.5691
		display_data(seconds, params.horizon, config.no_units, params.no_events, height, width, objective, candidates[best_index], params.generations, bests, avgs)
		sleep(seconds)
		run(`clear`)
	end
	best_index, best_fitness
end
