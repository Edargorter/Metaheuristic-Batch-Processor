import matplotlib.pyplot as plt
import csv
from sys import argv

#Example format of log

'''
Generation: 1	 ----- Average Fitness: 0.9553333426882982 	----- Best: 0.0
Generation: 2	 ----- Average Fitness: 4.189564648888063 	----- Best: 50.0
Generation: 3	 ----- Average Fitness: 20.54010944461793 	----- Best: 51.697928439181275
Generation: 4	 ----- Average Fitness: 30.858187667731244 	----- Best: 63.66117803385822
Generation: 5	 ----- Average Fitness: 42.677358001669475 	----- Best: 67.4115571330816
Generation: 6	 ----- Average Fitness: 48.4665134121711 	----- Best: 70.28763620635885
Generation: 7	 ----- Average Fitness: 52.825296025356344 	----- Best: 70.819823756034
Generation: 8	 ----- Average Fitness: 56.90746271806742 	----- Best: 71.11264626395962
Generation: 9	 ----- Average Fitness: 57.0313387684072 	----- Best: 71.26994434578008
Generation: 10	 ----- Average Fitness: 56.85592870106185 	----- Best: 71.40845566968862
Generation: 11	 ----- Average Fitness: 55.93376997797975 	----- Best: 71.42202581905903
Generation: 12	 ----- Average Fitness: 57.387990749161396 	----- Best: 71.45374076821099
Generation: 13	 ----- Average Fitness: 56.82322874921353 	----- Best: 71.46071438070598
Generation: 14	 ----- Average Fitness: 54.2911184501998 	----- Best: 71.46596595453771
Generation: 15	 ----- Average Fitness: 54.10613738788905 	----- Best: 71.46715183065902
Generation: 16	 ----- Average Fitness: 52.131641107009436 	----- Best: 71.47078379001303
Generation: 17	 ----- Average Fitness: 53.20456103639036 	----- Best: 71.47256065293402
Generation: 18	 ----- Average Fitness: 55.80313874069973 	----- Best: 71.47283134148617
Generation: 19	 ----- Average Fitness: 54.922670590651826 	----- Best: 71.4729864445993
Generation: 20	 ----- Average Fitness: 57.659142546679035 	----- Best: 71.47306755783052
Generation: 21	 ----- Average Fitness: 58.20770496818113 	----- Best: 71.47326455285793
Generation: 22	 ----- Average Fitness: 57.16569211602012 	----- Best: 71.47328389933222
Generation: 23	 ----- Average Fitness: 58.709583212103254 	----- Best: 71.47332645829474
Generation: 24	 ----- Average Fitness: 56.61590682677602 	----- Best: 71.47335022266395
Generation: 25	 ----- Average Fitness: 58.40518333615799 	----- Best: 71.47335158436711
'''

def get_values(n):
	return [i for i in range(1, n + 1)]

def get_col_labels(n):
	return ["col{}".format(i) for i in range(1, n + 1)]

if len(argv) < 5:
	print("Usage: python3 {} [no_tests] [generations] [filename] [val] ".format(argv[0]))
	exit(1)

no_tests = int(argv[1])
generations = int(argv[2])
filename = argv[3]
milp_val = float(argv[4])

avgs = []
bests = []

get_error = True

if get_error:
	plt.ylabel("Error (from S&M value) (percent)")
	plt.title("Error of Solutions (30) vs Generations")
else: 
	plt.ylabel("Fitness (Tonnage)")
	plt.title("Fitness of Solutions (30) vs Generations")

xs = get_values(generations)

with open(filename, 'r') as f:

	for t in range(no_tests):
		avg_fitnesses = []
		best_fitnesses = []
		f.readline()

		for i in range(generations):	
			line = f.readline()
			data = line.split()
			avg_fitnesses.append(float(data[5]))
			best_fitnesses.append(float(data[8]))


		if get_error:
			for a in range(len(avg_fitnesses)):
				avg_fitnesses[a] = 100 * (1.0 - avg_fitnesses[a] / milp_val)
				best_fitnesses[a] = 100 * (1.0 -  best_fitnesses[a] / milp_val)

		avgs.append(avg_fitnesses.copy())
		bests.append(best_fitnesses.copy())

		plt.plot(xs, avg_fitnesses)

f.close()

output = "plot3.csv"
of = open(output, 'w')
writer = csv.writer(of)
cl = get_col_labels(no_tests + 1)
writer.writerow(cl)

for i in range(generations):
	row = [i + 1]
	for j in range(no_tests):
		row.append(avgs[j][i])
	writer.writerow(row)

of.close()

plt.xlabel("Generations")
plt.savefig("30_trials_graph.png")
plt.show()
