old = [11.451, 34.386, 36.333, 52.4712, 124.210, 127.338, 261.365, 277.997, 293.560]
first = [0.29, 1.51, 1.54, 2.64, 6.37, 6.59, 16.09, 18.25, 21.21]
second = [0.26, 1.36, 1.41, 2.41, 5.93, 6.2, 15.26, 16.98, 20.47]
third = [0.31, 1.59, 1.62, 2.82, 6.66, 7.25, 18.06, 19.6, 22.13]

def inc(a, b):
    return (a - b) / b

for i in range(len(first)):
    ov = old[i]
    a = inc(ov, first[i])
    b = inc(ov, second[i])
    c = inc(ov, third[i])
    print("GA1: {} GA2: {} GA3: {}".format(a, b, c))
