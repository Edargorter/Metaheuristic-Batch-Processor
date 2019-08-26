#!/bin/bash

threads=2

echo "Running 'julia -p $threads bp_primary_problem.jl' -> output: $1"
julia -p $threads bp_primary_problem.jl | sudo tee $1
