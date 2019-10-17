#!/bin/bash -e

mv random.txt ..
if [ $? -eq 0 ]; then
	echo "Success."
else
	echo "Move to Test directory."
fi
