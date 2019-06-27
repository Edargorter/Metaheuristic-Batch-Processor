# Structures for batch processing problems

# Reaction duration coefficients
struct Coefs
	alpha::Float64
	beta::Float64
end

struct Task
	name::String
	feeders::Dict{Int, Float64}
	receivers::Dict{Int, Float64}
end

# Unit specifications
struct Unit
	capacity::Float64

	# IN/OUT storage containments with consumption / production ratios
	tasks::Dict{Int, Coefs}
end

# Parameter configurations for a batch process of this complexity
struct BPS_Config
	# Numbers
	no_units::Int
	no_storages::Int
	no_instructions::Int
	products::Array{Int}
	prod_reactions::Dict{Int, Int}
	prices::Array{Int}

	# Unit constraints
	units::Array{Unit}

	#Tasks
	tasks::Array{Task}

	# Storage constraints
	storage_capacity::Array{Float64}
end

# State tracking for fitness evaluation
struct BPS_State
	# Volumes
	unit_amounts::Array{Float64, 2}
	unit_active::Array{Int, 2}
	storage_amounts::Array{Float64}
end

# Individual data values for batch process program
struct BPS_Program
	instructions::Array{Int, 2}
	durations::Array{Float64}
end

##### Metaheuristic parameters #####

struct Params
	horizon::Float64
	no_events::Int
	population::Int
	generations::Int
	theta::Float64
	mutation_rate::Float64
	delta::Float64
end
