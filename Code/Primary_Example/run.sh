#!/bin/bash

echo "Running 'julia bp_primary_problem.jl' -> output: $1"
julia bp_primary_problem.jl | tee $1
