#!/bin/bash

<<<<<<< HEAD
echo "Running 'julia -p 2 bp_primary_problem.jl' -> output: $1"
julia -p 2 bp_primary_problem.jl | sudo tee $1
=======
echo "Running 'julia bp_primary_problem.jl' -> output: $1"
julia bp_primary_problem.jl > $1

echo "Running 'julia bp_primary_problem_rates.jl' -> output: $2"
julia bp_primary_problem_rates.jl > $2
>>>>>>> b5bcc9183c8b69386a09f5be23778b158a291be6
