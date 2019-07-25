# Zachary Bowditch 2019 #
#= ===== Batch Processing System functions ===== =#


#= 
	
	Contents (Unique Search Strings):

	Section								Key (search)

	1) Helper functions:				hfuncs
	2) I/O data handling functions:		inout
	3) Data generation:					dgen	

=#


using Printf
using StatsBase
using Dates
using Random

include("bp_primary_structs.jl") # Structures for relevent data representations

Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

### key=hfuncs Helper functions ###

function set_array(a::Array{Float64}, b::Array{Float64})
	for i in 1:length(a) a[i] = b[i] end
end

# Copy state
function copy_state(state::BPS_State)
	BPS_State(state.unit_amounts, state.storage_amounts)
end

function string_to_float_array(float_string)
	[parse(Float64, c) for c in split(float_string, ",")]
end

function string_to_int_array(int_string)
	[parse(Int, c) for c in split(int_string, ",")]
end

### End of helper functions ###

### key=inout I/O BPS_Program candidates ###

#Convert candidate to string
function candidate_to_string(candidate::BPS_Program, config::BPS_Config, params::Params)
	output::String = ""
	for unit in 1:config.no_units
		for event in 1:params.no_events
			output *= string(candidate.instructions[unit, event])
			if !(unit == config.no_units && event == params.no_events) output *= "," end
		end
	end
	output *= ";"
	for event in 1:params.no_events
		if event != 1 output *= "," end
		output *= string(candidate.durations[event])
	end
	output
end

# Write candidates to filename
function save_candidates(filename::String, candidates::Array{BPS_Program}, config::BPS_Config)
	open(filename, "w") do file
		write(file, "$(config.no_units) $(params.no_events) \n")
		for i in 1:length(candidates)
			write(file, candidate_to_string(candidates[i], config))
			write(file, "\n")
		end
	end
end

# Convert string to BPS Program structure
function string_to_program(program::String, config::BPS_Config, params::Params)
	info::Array{String} = split(program, ";")
	instructions::Array{Int, 2} = reshape([parse(Float64, s) for s in split(info[1], ",")], (config.no_units, params.no_events))
	durations::Array{Float64} = [parse(Float64, s) for s in split(info[2], ",")]
	BPS_Program(instructions, durations)
end

# Get candidates file data
function read_candidates(filename::String, config::BPS_Config)
	candidates::Array{BPS_Program} = []
	file = open(filename)
	no_units::Int, no_events::Int = [parse(Int, n) for n in split(readline(file))]
	for l in eachline(file) push!(candidates, string_to_program(l, config)) end
	close(file)
	candidates
end

#Convert string to unit structure
function string_to_unit(unit_string::String)
	info::Array{String} = split(unit_string, ":")
	name::String = info[1]
	values::Array{String} = split(info[2], ",")
	capacity::Float64 = parse(Float64, values[1])
	d = Dict{Int, Float64}()
	for r in 1:(values/3)
		reaction::Int = parse(Int, values[r + 1])
		d[reaction] = Coefs(parse(Float64, values[r + 2]), parse(Float64, values[r + 3]))	
	end
	Unit(name, capacity, feeder, receiver, alpha, beta)
end

#Get config data
function read_config(filename::String)
	file = open(filename)
	no_units::Int = parse(Float64, split(readline(file), ":")[2])
	no_storages::Int = parse(Float64, split(readline(file), ":")[2])
	no_instructions::Int = parse(Int, split(readline(file), ":")[2])
	products::Array{Int} = string_to_int_array(split(readline(file), ":")[2])
	storage_capacity::Array{Float64} = string_to_float_array(split(readline(file), ":")[2])
	initial_storage_amounts::Array{Float64} = string_to_float_array(split(readline(file), ":")[2])

	units::Array{Unit} = Array{Unit}(undef, no_units)
	for u in 1:no_units units[u] = string_to_unit(readline(file)) end
	BPS_Config(no_units, no_storages, no_instructions, product, units, storage_capacity)
end

function read_parameters(filename::String)
	file = open(filename)
	horizon::Float64 = parse(Float64, split(readline(file), ":")[2])
	no_events::Int = parse(Int, split(readline(file), ":")[2])
	population::Int = parse(Int, split(readline(file), ":")[2])
	generations::Int = parse(Int, split(readline(file), ":")[2])
	theta::Float64 = parse(Float64, split(readline(file), ":")[2])
	mutation_rate::Float64 = parse(Float64, split(readline(file), ":")[2])
	delta::Float64 = parse(Float64, split(readline(file), ":")[2])
	Params(horizon, no_events, population, generations, theta, mutation_rate, delta)
end

### key=pdata Print data ###

function print_instructions(prog::BPS_Program, config::BPS_Config, params::Params)
	@printf "Instructions: \n\n"
	for unit in 1:config.no_units
		@printf "Unit %d: " unit
		for event in 1:params.no_events
			@printf "%d " prog.instructions[unit, event]
		end
		@printf "\n"
	end
	@printf "\n"
end

function print_durations(prog::BPS_Program, config::BPS_Config, params::Params)
	@printf "Durations: \n\n"
	for event in 1:params.no_events
		@printf "%d:%.3f " event prog.durations[event]
	end
	@printf "\n"
end

### key=dgen Data generation ###

# Instruction Array
function get_random_instructions(config::BPS_Config, params::Params)
	instr_arr::Array{Int, 2} = zeros(config.no_units, params.no_events) #Initialise instruction array to zeros

	for unit in 1:config.no_units
		tasks::Array{Int} = [[0]; collect(keys(config.units[unit].tasks))]
		index_range::Int = size(tasks)[1]

		for event in 1:params.no_events
			instr_arr[unit, event] = tasks[rand(1:index_range)]
		end
	end

	instr_arr
end

# Time Interval Array
function get_random_durations(config::BPS_Config, params::Params)
	stamps = sort(params.horizon*rand(params.no_events - 1))
	time_intervals = Array{Float64}(undef, params.no_events)
	time_intervals[end] = params.horizon - stamps[end]
	for i in params.no_events - 1:-1:2 time_intervals[i] = stamps[i] - stamps[i - 1] end
	time_intervals[1] = stamps[1]
	time_intervals
end

# Random BPS_Program structure
function get_random_program(config::BPS_Config, params::Params)
	instructions::Array{Int, 2} = get_random_instructions(config, params)
	durations::Array{Float64} = get_random_durations(config, params)
	BPS_Program(instructions, durations)
end

function generate_pool(config::BPS_Config, params::Params)
	Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))
	print(config.units)
	candidates::Array{BPS_Program} = Array{BPS_Program}(undef, params.population)
	for i in 1:params.population candidates[i] = get_random_program(config, params) end
	candidates
end
