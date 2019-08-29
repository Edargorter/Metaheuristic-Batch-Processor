#Read in saved test data (Best results recorded)
from sys import argv

#Format 

'''
Horizon: 12.0 Events: 4 Generations: 25 Population: 500     --- Total Time: 1.275298 Optimal Fitness: 71.473351 [1 1 1 1; 0 1 1 1; 1 1 1 1][4.66458, 3.47962, 2.42633, 1.42947]
'''

in_file = argv[1]
out_file = argv[2]

f = open(in_file, 'r')
for line in f:
	data = line.split()
	
