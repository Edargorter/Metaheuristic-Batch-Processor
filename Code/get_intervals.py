def get_intervals(arr):
	print(arr[0], end=" ")
	for i in range(1, len(arr)):
		print(round(arr[i] - arr[i - 1], 3), end=" ")
	print()

a = [1.135, 2.097, 2.611, 4.75, 5.085, 6.077, 7.038, 8.00]
b = [6, 12, 15.519, 17.95, 19.42, 23.466, 25.645, 27.546, 29.437, 31.365, 36]

get_intervals(b)
