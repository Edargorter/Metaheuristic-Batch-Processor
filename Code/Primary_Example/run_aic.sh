#!/bin/bash

echo "Running 'bp_aic_problem.jl' -> output: aic_results.txt"
time julia bp_aic_problem > aic_results.txt
