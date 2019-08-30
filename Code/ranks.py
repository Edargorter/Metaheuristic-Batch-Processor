from sys import argv
import csv

no_tests = 30
gp = [[(1000, 50), (1000, 50), (1000, 50), (2000, 100), (2000, 100), (2000, 100)], [(1000, 50), (2000, 100), (2000, 100), (2000, 150), (4000, 150), (4000, 150), (8000, 150), (8000, 150), (8000, 150)]]
suffixes = ["_", "_rates_", "_normal_"]
in_files = ["naive_results.txt", "rates_results.txt", "normal_results.txt"]

first_out = "motivating_out.csv"
second_out = "primary_out.csv"

first_table_data = []
second_table_data = []

### Columns
col_names = "Model,Hours,Events,CPU Times (s),Rank 1/5/10"

one = "S\&M"
two = "GA1"
three = "GA2"
four = "GA3"

first_example = "Motivating_Example"
second_example = "Primary_Example"

f = open(first_example + "/" + in_files[0], 'r')
f1 = open(first_example + "/" + in_files[1], 'r')
f2 = open(first_example + "/" + in_files[2], 'r')
sm = open("sandm_motivating.txt", 'r')

def get_ranks(e, p, mu, suffix):
	# Log files
	best_of_trials = []

	if e == 0:
		folder = first_example
	else:
		folder = second_example

	fn = open(folder + "/" + "log" + suffix + str(p) + ".txt", 'r')

	for tt in range(no_tests):
		print(gp[e][p - 1][1])
		for it in range(gp[e][p - 1][1]): 
			line = fn.readline()

		line = fn.readline().split()

		if e == 1:
			print(par)
			print(line)

		best_of_trials.append(float(line[8]))

	if e == 1:
		print(best_of_trials)

	best_of_trials = sorted(best_of_trials, reverse=True)

	nn = 0
	nf = 0
	n = 0
	count = 0
	l = len(best_of_trials)

	while count < l and best_of_trials[count] >= 0.99 * mu:
		nn += 1
		nf += 1
		n += 1
		count += 1

	while count < l and best_of_trials[count] >= 0.95 * mu:
		nf += 1
		n += 1
		count += 1

	while count < l and best_of_trials[count] >= 0.9 * mu:
		n += 1
		count += 1

	return "{}/{}/{}".format(round(100*nn/no_tests, 2), round(100*nf/no_tests, 2), round(100*n/no_tests, 2))

par = 1

for line in f:
	data = line.split()

	line1, line2 = f1.readline(), f2.readline()
	data1, data2 = line1.split(), line2.split()

	linesm = sm.readline()
	sml = linesm.split()
	mu = float(sml[3])

	row1 = [one, int(sml[0]), int(sml[1]), float(sml[2]), mu]
	row2 = [two, int(float(data[1])), int(data[3]), float(data[11])/no_tests, get_ranks(0, par, mu, suffixes[0])]
	row3 = [three, int(float(data1[1])), int(data1[3]), float(data1[11])/no_tests, get_ranks(0, par, mu, suffixes[1])] 
	row4 = [four, int(float(data2[1])), int(data2[3]), float(data2[11])/no_tests, get_ranks(0, par, mu, suffixes[2])]
	par += 1
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

par = 1
for line in f:
	data = line.split()

	line1, line2 = f1.readline(), f2.readline()
	data1, data2 = line1.split(), line2.split()

	linesm = sm.readline()
	sml = linesm.split()
	mu = float(sml[3])

	row1 = [one, int(sml[0]), int(sml[1]), float(sml[2]), mu]
	row2 = [two, int(float(data[1])), int(data[3]), float(data[11])/no_tests, get_ranks(1, par, mu, suffixes[0])]
	row3 = [three, int(float(data1[1])), int(data1[3]), float(data1[11])/no_tests, get_ranks(1, par, mu, suffixes[1])] 
	row4 = [four, int(float(data2[1])), int(data2[3]), float(data2[11])/no_tests, get_ranks(1, par, mu, suffixes[2])]
	par += 1

	second_table_data.append(row1)
	second_table_data.append(row2)
	second_table_data.append(row3)
	second_table_data.append(row4)

f.close()
f1.close()
f2.close()
sm.close()

### Print to CSV
with open(first_out, 'w') as cf:
	writer = csv.writer(cf)
	for row in first_table_data:
		writer.writerow(row)

cf.close()

with open(second_out, 'w') as cf:
	writer = csv.writer(cf)
	for row in second_table_data:
		writer.writerow(row)

cf.close()
