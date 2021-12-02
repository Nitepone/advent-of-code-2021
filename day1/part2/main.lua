#! /usr/bin/env lua
--
-- main.lua
-- Copyright (C) 2021 Tyler Hart <admin@night.horse>
--
-- Distributed under terms of the MIT license.
--

DEBUG = true;

function print_dbg(str)
	if DEBUG then print(str) end
end

function file_into_arr(filepath, line_fn)
	local file = io.open(filepath, "r");
	local arr = {};
	for line in file:lines() do
		table.insert(arr, line_fn(line));
	end
	return arr
end

-- Compares all neighbors of an array using function "fn" where "fn" has
-- signature "bool fn(a,b)" where a is the left neighbor, and b is the right
-- neighbor.
-- Returns the count of "true" responses from "fn".
function compare_neighbors_arr(arr, fn)
	local count = 0;
	local fn_ret;
	if #arr < 1 then return count end;
	print_dbg(string.format("%d (N/A)", arr[1]));
	for i=2,(#arr) do
		fn_ret = fn(arr[i-1], arr[i]);
		if fn_ret then
			count = count + 1;
		end
		print_dbg(string.format("%d (%s)", arr[i], tostring(fn_ret)))
	end
	return count
end

-- Sums up an array using a sliding window.
-- e.g. If using a window_size of 3, the conversion will be such that:
--      new_arr[i] = arr[i] + arr[i+1] + arr[i+2]
-- (This will reduce array size by (window_size - 1)).
function arr_to_sum_arr(arr, window_size)
	local new_arr = {};
	local sum;
	local window_offset = window_size - 1;
	if #arr < window_offset then return new_arr end;
	for i=1,(#arr-(window_offset)) do
		sum = 0;
		for j=0,(window_offset) do
			sum = sum + arr[i+j]
		end
		table.insert(new_arr, sum)
	end
	return new_arr
end

local arr = arr_to_sum_arr(file_into_arr("input.txt", tonumber), 3);
local count = compare_neighbors_arr(arr, (function(a,b)return(a<b)end));
print(count);
