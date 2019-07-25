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
include("mh_params.jl")

#Random seed based on number of milliseconds of current date
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now()))) 
rng = MersenneTwister(Dates.value(convert(Dates.Millisecond, Dates.now())))

##### key=wprod WEED PRODUCTION #####

function weeds_to_produce(fitness::Float64, f_min::Float64, f_max::Float64, params::Params)
	floor(Int, params.s_min + (params.s_max - params.s_min) * (fitness - f_min) / (f_max - params.f_min))
end

# Get the new standard deviation
function get_sigma(params::Params, iter::Int)
	(((params.iter_max - iter) / params.iter_max - 1)^params.n) * (params.sig_init - params.sig_final) + params.sig_final
end

function get_cand(mean::Float64, n::Int)
	index::Int = celi(abs(randn(rng)) * n + mean)
	index
end

function invade(params::Params)
	sigma::Float64 = 0
	for it in 1:params.iterations	
		sigma = get_sigma(params, it)

		# Get costs of population
		# Get max cost of population
		# Get min cost of population

		# Generate new population
	end
end

#=

Use normal curve to generate progeny integrated with GA 

I.e. highest fitness generates most offspring proportionally to normal distribution with mean 0.

Chop off lower fitness solutions to reach population

=#
