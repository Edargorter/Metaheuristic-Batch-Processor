#!/bin/bash

echo "Running 'julia bp_primary_problem.jl' -> output: grid_search_naives.txt"
time julia bp_primary_problem.jl > grid_search_naive.txt

echo "Running 'julia bp_primary_problem_rates.jl' -> output: grid_search_rates.txt"
time julia bp_primary_problem_rates.jl > grid_search_rates.txt 

echo "Running 'julia bp_primary_problem_normal.jl' -> output: grid_search_normal.txt"
time julia bp_primary_problem_normal.jl > grid_search_normal.txt
