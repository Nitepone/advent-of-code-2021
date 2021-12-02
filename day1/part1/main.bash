#! /bin/bash
#
# main.bash
#
# This exists because I forgot to use "tonumber" when reading the input file
# in Lua... Causing the code to compare the values from the input file as
# strings.
# This is just some gnarly working bash solution to debug that issue.
#
# Copyright (C) 2021 Tyler Hart <admin@night.horse>
#
# Distributed under terms of the MIT license.
#

arr=($(cat input.txt))
prev=${arr[0]}
count=0
for v in ${arr[@]}; do
	if [ $prev -lt $v ]; then
		echo "$v (true)"
		count=$(($count+1))
	else
		echo "$v (false)"
	fi
	prev=$v
done

echo $count
