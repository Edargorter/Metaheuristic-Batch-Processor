#!/bin/bash

echo "Running 'julia bp_motivating_problem.jl' -> output: naive_results.txt"
time julia bp_motivating_problem.jl > naive_results.txt

echo "Running 'julia bp_motivating_problem_rates.jl' -> output: rates_results.txt"
time julia bp_motivating_problem_rates.jl > rates_results.txt 

 echo "Running 'julia bp_motivating_problem_normal.jl' -> output: normal_results.txt"
time julia bp_motivating_problem_normal.jl > normal_results.txt
