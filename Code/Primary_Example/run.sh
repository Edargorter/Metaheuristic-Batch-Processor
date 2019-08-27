#!/bin/bash

echo "Running 'julia bp_primary_problem.jl' -> output: $1"
julia bp_primary_problem.jl > $1

echo "Running 'julia bp_primary_problem_rates.jl' -> output: $2"
julia bp_primary_problem_rates.jl > $2

echo "Running 'julia bp_primary_problem_normal.jl' -> output: $2"
julia bp_primary_problem_normal.jl > $3
