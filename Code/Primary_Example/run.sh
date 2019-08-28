#!/bin/bash

echo "Running 'julia bp_primary_problem.jl' -> output: naive_results.txt"
julia bp_primary_problem.jl > naive_results.txt

echo "Running 'julia bp_primary_problem_rates.jl' -> output: rates_results.txt"
julia bp_primary_problem_rates.jl > rates_results.txt 

echo "Running 'julia bp_primary_problem_normal.jl' -> output: normal_results.txt"
julia bp_primary_problem_normal.jl > normal_results.txt
