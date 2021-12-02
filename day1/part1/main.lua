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

local arr = file_into_arr("input.txt", tonumber);
local count = compare_neighbors_arr(arr, (function(a,b)return(a<b)end));
print(count);
