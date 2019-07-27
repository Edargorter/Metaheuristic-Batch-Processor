def get_intervals(arr):
	print(arr[0], end=" ")
	for i in range(1, len(arr)):
		print(round(arr[i] - arr[i - 1], 3), end=" ")
	print()

a = [1.135, 2.097, 2.611, 4.75, 5.085, 6.077, 7.038, 8.00]

get_intervals(a)
