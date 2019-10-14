# Structures for batch processing systems representations 

# Reaction duration coefficients
struct Coefs
	alpha::Float64
	beta::Float64
end

struct RTask
	name::String

	#Associated feeder / receiver storage containments with respective consumption / production ratios
	feeders::Dict{Int, Float64}    
	receivers::Dict{Int, Float64} 
end

# Unit specifications
struct Unit
	name::String 
	capacity::Float64

	#Associated tasks with alpha/beta rate coefficients
	tasks::Dict{Int, Coefs}  
end

struct BPS_Storage
	name::String
	capacity::Float64 

	# Task feeders / receivers 
	feeders::Array{Int}
	receivers::Array{Int}
end

# Parameter configurations for a batch process of this complexity
struct BPS_Config
	# Numbers
	no_units::Int
	no_storages::Int
	no_instructions::Int
	products::Array{Int}
	prices::Array{Int}

	# Unit constraints
	units::Array{Unit}

	#Tasks
	tasks::Array{RTask}

	# Storages
	storages::Array{BPS_Storage}

	#Initial volumes
	initial_volumes::Array{Float64}
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
