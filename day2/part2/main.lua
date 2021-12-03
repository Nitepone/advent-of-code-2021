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

function newSubmarine()
	local self = {x_pos = 0, z_pos = 0, aim = 0}

	local adjust_aim = function (a)
		self.aim = self.aim + a
	end

	local move_forward = function (d)
		self.x_pos = self.x_pos + d
		self.z_pos = self.z_pos + (self.aim * d)
	end

	local print_pos = function ()
		print(string.format("%d,%d", self.x_pos, self.z_pos))
	end

	local print_pos_mult = function ()
		print(self.x_pos * self.z_pos)
	end

	local move_by_str = function (str)
		local move_fn_arr = {
			["forward"] = move_forward,
			["down"] = adjust_aim,
			["up"] = function(neg_aim) adjust_aim(-neg_aim) end
		}
		local args = {}
		local move_fn
		-- Split string into args
		for w in str:gmatch("%S+") do table.insert(args, w) end
		-- Validate arg count
		if #args ~= 2 then
			print_err("sub.move_by_str: Must have 2 args!")
			return false
		end
		-- Get move function
		move_fn = move_fn_arr[args[1]]
		move_count = tonumber(args[2])
		-- Validate movement function and count
		if not move_fn or not move_count then
			print_err("sub.move_by_str: Invalid args in string!")
			return false
		end
		move_fn(move_count)
		return true
	end

	return {
		print_pos = print_pos,
		print_pos_mult = print_pos_mult,
		move_by_str = move_by_str
	}
end

sub = newSubmarine()
file_into_arr("input.txt", sub.move_by_str)
sub.print_pos()
sub.print_pos_mult()
