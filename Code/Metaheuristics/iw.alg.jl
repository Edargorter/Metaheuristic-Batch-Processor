####### METAHEURISTIC #####################
####### Invasive Weed Optimisation ########


#=

	Contents (Unique Search Strings):
		
	Section								Key (search)

	1) Imports							imps
	2)
	3)
	4)

=#

##### key=imps Imports #####

using Random
using Dates
using StatsBase

include("bp_motivating_fitness.jl")
include("bp_literature_fitness.jl")

#Random seed based on number of milliseconds of current date
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 


