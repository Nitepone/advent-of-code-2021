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

function print_err(str)
	print(str)
end

function file_into_arr(filepath, line_fn)
	local file = io.open(filepath, "r");
	local arr = {};
	for line in file:lines() do
		table.insert(arr, line_fn(line));
	end
	return arr
end

function newDiag(arr)
	local self = {arr = arr}

	local get_bit_sums = function()
		local bit_conv_table = {
			["1"] = 1,
			["0"] = 0
		}
		local bit_sums = {}
		local bit_val
		local bit_pos
		for _,value in pairs(self.arr) do
			bit_pos = 1
			for char in value:gmatch"." do
				bit_val = bit_conv_table[char]
				bit_sums[bit_pos] =
						(bit_sums[bit_pos] or 0)
						+ bit_val
				bit_pos = bit_pos + 1
			end
		end
		return bit_sums
	end

	local get_gamma = function()
		local total_values = #self.arr
		local bit_sums = get_bit_sums()
		local bit_string = ""
		for _,v in pairs(bit_sums) do
			if v > (total_values / 2) then
				bit_string = bit_string .. "1"
			else
				bit_string = bit_string .. "0"
			end
		end
		return tonumber(bit_string, 2)
	end

	local get_epsilon = function()
		local total_values = #self.arr
		local bit_sums = get_bit_sums()
		local bit_string = ""
		for _,v in pairs(bit_sums) do
			if v < (total_values / 2) then
				bit_string = bit_string .. "1"
			else
				bit_string = bit_string .. "0"
			end
		end
		return tonumber(bit_string, 2)
	end

	local print_res = function()
		for _,v in pairs(get_bit_sums()) do
			print_dbg(v)
		end
		print("gamma", get_gamma())
		print("epsilon", get_epsilon())
		print("product", get_gamma() * get_epsilon())
	end

	return {
		get_bit_sums = get_bit_sums,
		print_res = print_res
	}
end

diag = newDiag(file_into_arr("input.txt", tostring))
diag.print_res()
