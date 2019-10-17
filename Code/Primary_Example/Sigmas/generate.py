import os

for p in range(1, 10):
	for s in range(1, 101):
		os.system("touch sigma_{}_{}.txt".format(p, s))
