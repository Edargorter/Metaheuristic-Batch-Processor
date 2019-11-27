# Structures for batch processing systems representations 

# Reaction duration coefficients
struct MBP_Coefs
	alpha::Float64
	beta::Float64
end

struct MBP_Task
	name::String

	#Associated feeder / receiver storage containments with respective consumption / production ratios
	feeders::Dict{Int, Float64}    
	receivers::Dict{Int, Float64} 
end

# MBP_Unit specifications
struct MBP_Unit
	name::String 
	capacity::Float64

	#Associated tasks with alpha/beta rate coefficients
	tasks::Dict{Int, MBP_Coefs}  
end

struct MBP_Storage
	name::String
	capacity::Float64

	# Reactor feeders / receivers 
	feeders::Array{Int}
	receivers::Array{Int}
end

# Parameter configurations for a batch process of this complexity
struct MBP_Config
	# Numbers
	no_units::Int
	no_storages::Int
	no_instructions::Int
	products::Array{Int}
	prices::Array{Int}

	# MBP_Unit constraints
	units::Array{MBP_Unit}

	#Tasks
	tasks::Array{MBP_Task}

	#Storages
	storages::Array{MBP_Storage}
	
	#Initial volumes
	initial_volumes::Array{Float64}
end

# State tracking for fitness evaluation
struct MBP_State
	# Volumes
	unit_amounts::Array{Float64, 2}
	unit_active::Array{Int, 2}
	storage_amounts::Array{Float64}
end

# Individual data values for batch process program
struct MBP_Program
	instructions::Array{Int, 2}
	durations::Array{Float64}
end
