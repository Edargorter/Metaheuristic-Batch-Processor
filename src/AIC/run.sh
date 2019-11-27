#!/bin/bash -e

julia bp_aic_problem.jl | tee aic_naive.txt
julia bp_aic_problem_rates.jl | tee aic_rates.txt
julia bp_aic_problem_normal.jl | tee aic_normal.txt
echo DONE
