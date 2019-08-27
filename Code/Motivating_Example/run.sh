#!/bin/bash

echo "Running 'julia bp_motivating_problem.jl' -> output: $1"

julia -p 2 bp_motivating_problem.jl | tee -a $1

echo "Done. Output -> $1"
