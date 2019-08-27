#!/bin/bash

echo "Running 'julia -p 2 bp_primary_problem.jl' -> output: $1"
julia -p 2 bp_primary_problem.jl | sudo tee $1
