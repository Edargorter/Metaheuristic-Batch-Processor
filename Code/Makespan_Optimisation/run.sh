#!/bin/bash

julia mbp_makespan_optimisation.jl | tee first_results.txt

julia mbp_2nd_makespan_optimisation.jl | tee second_results.txt

#julia mbp_proportional.jl | tee prop_first_results.txt

#julia mbp_2nd_proportion.jl | tee prop_second_results.txt

julia mbp_estimate_upper.jl | tee first_eu_results.txt

julia mbp_2nd_estimate_upper.jl | tee second_eu_results.txt
