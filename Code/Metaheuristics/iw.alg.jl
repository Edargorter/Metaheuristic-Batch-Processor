####### METAHEURISTIC #####################
####### Invasive Weed Optimisation ########


#=

	Contents (Unique Search Strings):
		
	Section								Key (search)

	1) Imports							imps
	2) Weed Production					wprod
	3)
	4)

=#

##### key=imps Imports #####

using Random
using Dates
using StatsBase
#Not absolute paths

include("bp_motivating_fitness.jl") 
include("bp_literature_fitness.jl")

#Random seed based on number of milliseconds of current date
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 

##### key=wprod WEED PRODUCTION #####

function weeds_to_produce(fitness::Float64, f_min::Float64, f_max::Float64, params::Params)
	params.s_min + (params.s_max - params.s_min) * (fitness - f_min) / (f_max - params.f_min)
end

function get_std_dev(iter_max::Int, iter::Int, n::Int, std_init::Float64, std_final::Float64)
	(((iter_max - iter) / iter_max )^n) * (std_init - std_final) + std_final
end

#=

Use normal curve to generate progeny integrated with GA 

I.e. highest fitness generates most offspring proportionally to normal distribution with mean 0.

Chop off lower fitness solutions to reach population

=#
