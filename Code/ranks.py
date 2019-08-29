from sys import argv

gp = [(1000, 50), (1000, 50), (1000, 50), (2000, 100), (2000, 100), (2000, 100)]
suffix = ["", "rates_", "normal_"]
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

# Log files
for i in range(1, 7):
	f = open(first_example + "/" + "log_" + suffix + 

for line in f:
    data = line.split()

    line1, line2 = f1.readline(), f2.readline()
    data1, data2 = line1.split(), line2.split()

    linesm = sm.readline()
    sml = linesm.split()

    row1 = [one, int(sml[0]), int(sml[1]), float(sml[2]), float(sml[3]), "-", "-"]
    row2 = [two, int(float(data[1])), int(data[3]), float(data[11]), float(data[14])]
    row3 = [three, int(float(data1[1])), int(data1[3]), float(data1[11]), float(data1[14])]
    row4 = [four, int(float(data2[1])), int(data2[3]), float(data2[11]), float(data2[14])]
