#Read in saved test data (Best results recorded)

from sys import argv
import csv

#Format of results output

'''
Horizon: 12.0 Events: 4 Generations: 25 Population: 500     --- Total Time: 1.275298 Optimal Fitness: 71.473351 [1 1 1 1; 0 1 1 1; 1 1 1 1][4.66458, 3.47962, 2.42633, 1.42947]
'''

in_files = ["naive_results.txt", "rates_results.txt", "normal_results.txt"]

first_out = "motivating_out.csv"
second_out = "primary_out.csv"

first_table_data = []

one = "S&M"
two = "GA1"
three = "GA2"
four = "GA3"

first_example = "Motivating_Example"
second_example = "Primary_Example"

f = open(first_example + "/" + in_files[0], 'r')
f1 = open(first_example + "/" + in_files[1], 'r')
f2 = open(first_example + "/" + in_files[2], 'r')
sm = open("sandm_motivating.txt", 'r')

for line in f:
	data = line.split()

	line1, line2 = f1.readline(), f2.readline()
	data1, data2 = line1.split(), line2.split()

	linesm = sm.readline()
	sml = linesm.split()

	row1 = [one, int(sml[0]), int(sml[1]), float(sml[2]), float(sml[3])]
	row2 = [two, int(float(data[1])), int(data[3]), float(data[11]), float(data[14])]
	row3 = [three, int(float(data1[1])), int(data1[3]), float(data1[11]), float(data1[14])]
	row4 = [four, int(float(data2[1])), int(data2[3]), float(data2[11]), float(data2[14])]

	first_table_data.append(row1)
	first_table_data.append(row2)
	first_table_data.append(row3)
	first_table_data.append(row4)

f.close()
f1.close()
f2.close()
sm.close()

f = open(second_example + "/" + in_files[0], 'r')
f1 = open(second_example + "/" + in_files[1], 'r')
f2 = open(second_example + "/" + in_files[2], 'r')
sm = open("sandm_primary.txt", 'r')

second_table_data = []

for line in f:
	data = line.split()

	line1, line2 = f1.readline(), f2.readline()
	data1, data2 = line1.split(), line2.split()

	linesm = sm.readline()
	sml = linesm.split()

	row1 = [one, int(sml[0]), int(sml[1]), float(sml[2]), float(sml[3])]
	row2 = [two, int(float(data[1])), int(data[3]), float(data[11]), float(data[14])]
	row3 = [three, int(float(data1[1])), int(data1[3]), float(data1[11]), float(data1[14])]
	row4 = [four, int(float(data2[1])), int(data2[3]), float(data2[11]), float(data2[14])]

	second_table_data.append(row1)
	second_table_data.append(row2)
	second_table_data.append(row3)
	second_table_data.append(row4)

f.close()
f1.close()
f2.close()
sm.close()

### PRINT TO CSV

with open(first_out, 'w') as cf:
	writer = csv.writer(cf)
	for row in first_table_data:
		writer.writerow(row)

cf.close()

with open(second_out, 'w') as cf:
	writer = csv.writer(cf)
	for row in first_table_data:
		writer.writerow(row)

cf.close()
