f = open("sigma_search.txt", "r")

lines = f.readlines()

for p in range(9):
    best = 0
    s = 0
    for i in range(100):
        data = lines[p*100 + i].split()
        obj = float(data[5])
        if obj > best:
            best = obj
            s = int(data[7])
    print("Sigma: {}".format(s))
    print(lines[p*100 + 100])
