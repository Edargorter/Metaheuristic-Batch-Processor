#Read in saved test data (Best results recorded)
from sys import argv

#Format 

'''
Horizon: 12.0 Events: 4 Generations: 25 Population: 500     --- Total Time: 1.275298 Optimal Fitness: 71.473351 [1 1 1 1; 0 1 1 1; 1 1 1 1][4.66458, 3.47962, 2.42633, 1.42947]
'''

in_files = ["naive_results.txt", "rates_results.txt", "normal_results.txt"]
out_file = argv[1]

table_data = []

first_example = "Motivating_Example"
second_example = "Primary_Example"

f = open(first_example + "/" + in_files[0], 'r')

for line in f:
	data = line.split()
	print(data)
	row = [0 for i in range(6)]
	
	row[0] = int(float(data[1]))
	row[1] = int(data[3])
	row[2] = int(data[5])
	row[3] = int(data[7])
	row[4] = float(data[11])
	row[5] = float(data[14])

	print(row)
