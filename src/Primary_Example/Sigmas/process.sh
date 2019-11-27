#!/bin/bash -e

for i in {1..9}; do
	touch change_$i.txt
	for j in {1..99}; do
		tail -n 1 sigma_$i\_$j.txt >> change_$i.txt
	done
done
