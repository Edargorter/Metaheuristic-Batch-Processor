#!/bin/bash

echo "Running 'julia bp_motivating_problem.jl' -> output: grid_search_naives.txt"
time julia bp_motivating_problem.jl | tee grid_search_naive.txt

echo "Running 'julia bp_motivating_problem_rates.jl' -> output: grid_search_rates.txt"
time julia bp_motivating_problem_rates.jl | tee grid_search_rates.txt 

echo "Running 'julia bp_motivating_problem_normal.jl' -> output: grid_search_normal.txt"
time julia bp_motivating_problem_normal.jl | tee grid_search_normal.txt
