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
	local bit_conv_table = {
		["1"] = 1,
		["0"] = 0
	}

	local get_len = function()
		return #self.arr
	end

	local get_bit_sums = function()
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

	local get_processed_child = function(trgt_val, pos)
		local child_arr = {}
		for _,v in pairs(self.arr) do
			if bit_conv_table[string.sub(v, pos, pos)] == trgt_val then
				table.insert(child_arr, v)
			end
		end
		return newDiag(child_arr)
	end

	local mode_in_pos = function(pos)
		sum = 0
		for _,v in pairs(self.arr) do
			sum = sum + bit_conv_table[string.sub(v, pos, pos)]
		end
		if sum > (#self.arr / 2) then
			return 1
		else
			return 0
		end
	end

	-- Gets the final element in self.arr if there is only one
	local get_final_elem = function()
		if get_len() == 1 then
			return self.arr[1]
		end
	end

	local get_oxygen = function()
		local bit_val = mode_in_pos(1)
		local bit_pos = 1
		local res = get_processed_child(bit_val, bit_pos)
		bit_pos = bit_pos + 1
		while res.get_len() > 1 do
			bit_val = res.mode_in_pos(bit_pos)
			res = res.get_processed_child(bit_val, bit_pos)
			bit_pos = bit_pos + 1
		end
		return tonumber(res.get_final_elem(), 2)
	end

	local get_co2 = function()
		local bit_val = (1 + mode_in_pos(1)) % 2
		local bit_pos = 1
		local res = get_processed_child(bit_val, bit_pos)
		bit_pos = bit_pos + 1
		while res.get_len() > 1 do
			bit_val = (1 + res.mode_in_pos(bit_pos)) % 2
			res = res.get_processed_child(bit_val, bit_pos)
			bit_pos = bit_pos + 1
		end
		return tonumber(res.get_final_elem(), 2)
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

	local print_contents = function()
		for _,v in pairs(self.arr) do
			print(v)
		end
	end

	local print_res = function()
		for _,v in pairs(get_bit_sums()) do
--			print_dbg(v)
		end
		print("gamma", get_gamma())
		print("epsilon", get_epsilon())
		print("product", get_gamma() * get_epsilon())
		print("oxygen", get_oxygen())
		print("co2", get_co2())
		print("life", get_co2() * get_oxygen())
	end

	return {
		get_len = get_len,
		get_bit_sums = get_bit_sums,
		print_res = print_res,
		print_contents = print_contents,
		get_processed_child = get_processed_child,
		mode_in_pos = mode_in_pos,
		get_final_elem = get_final_elem
	}
end

diag = newDiag(file_into_arr("input.txt", tostring))
diag.print_res()
