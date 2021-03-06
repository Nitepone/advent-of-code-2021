#! /usr/bin/env lua
--
-- main.lua
-- Copyright (C) 2021 Tyler Hart <admin@night.horse>
--
-- Distributed under terms of the MIT license.
--

function map(in_table, fn)
	out_table = {}
	for k,v in pairs(in_table) do
		table.insert(out_table, fn)
	end
	return out_table
end

function table_contains(table, trgt_v)
	for k,v in pairs(table) do
		if v == trgt_v then
			return true
		end
	end
	return false
end

function newBingoBoard()
	local self = {values = {}, called_values = {}}

	-- Loads the bingo board from an array of lines
	local build_from_file = function(str_arr)
		self.values = {}
		for i,line in pairs(str_arr) do
			self.values[i] = {}
			for val in string.gmatch(line, "[^ ]+") do
				table.insert(self.values[i], tonumber(val))
			end
		end
	end

	local check_win = function()
		local height = #self.values
		local width = #self.values[1] -- XXX ew.
		local uncalled_values
		-- check horizontal rows
		for i=1,height do
			uncalled_values = false
			for j=1,width do
				called = table_contains(
						self.called_values,
						self.values[i][j])
				if not called then
					uncalled_values = true
					break
				end
			end
			if not uncalled_values then
				return true
			end
		end
		-- check columns
		for i=1,width do
			uncalled_values = false
			for j=1,height do
				called = table_contains(
						self.called_values,
						self.values[j][i])
				if not called then
					uncalled_values = true
					break
				end
			end
			if not uncalled_values then
				return true
			end
		end
		-- getting here means no win
		return false
	end

	local new_called_number = function(v)
		table.insert(self.called_values, v)
		return check_win()
	end

	local print_board = function()
		for _,row in pairs(self.values) do
			for _,v in pairs(row) do
				io.write(v)
				io.write(" ")
			end
			io.write("\n")
		end
	end

	local unmarked_sum = function()
		local sum = 0
		for _,row in pairs(self.values) do
			for _,v in pairs(row) do
				if not table_contains(
					self.called_values,
					v)
				then
					sum = sum + v
				end
			end
		end
		return sum
	end


	return {
		build_from_file = build_from_file,
		check_win = check_win,
		new_called_number = new_called_number,
		print_board = print_board,
		unmarked_sum = unmarked_sum
	}
end

-- Reads a Game file into Bingo Boards
-- Game File Format:
--   Line 1: Comma seperated drawn numbers
--   Line 2: Empty
--   Line 3-7: Bingo Board Lines
--   Line 8 Empty
--   Etc...
function readBingoGameFile(filepath)
	local game_file = io.open(filepath, "r")
	local bingo_boards = {}
	local board_lines = {}
	local cur_board
	local cur_line = game_file:read("*line")
	-- Capture Line 1
	called_numbers = {}
	for v in string.gmatch(cur_line, "[^,]+") do
		table.insert(called_numbers, tonumber(v))
	end
	-- Enter Bingo Board Lines Loop
	repeat
		cur_line = game_file:read("*line")
		-- Bingo Board Data Line
		if cur_line and #cur_line > 0 then
			-- print("Cached Line", cur_line)
			table.insert(board_lines, cur_line)
		-- nil line or empty line
		else
			-- Create Board Object if Data Lines Cached
			if #board_lines > 0 then
				-- print("Creating Bingo Board")
				cur_board = newBingoBoard()
				cur_board.build_from_file(board_lines)
				table.insert(bingo_boards, cur_board)
				board_lines = {}
			end
		end
	until(not cur_line) -- nil cur_line means we are at EOF
	return called_numbers, bingo_boards
end

local called_numbers
local board_arr
local board_results
called_numbers, board_arr = readBingoGameFile("input.txt")
local winning_board
local winning_value
for i,num in pairs(called_numbers) do
	print("Start iter", i, num)
	for board_id,board in pairs(board_arr) do
		if board.new_called_number(num) then
			winning_board = board
			winning_value = num
			print("Winner!")
			print("Board ID", board_id)
			print("Last Num", num)
			board.print_board()
		end
	end
	if winning_board then break end
end

print(winning_board.unmarked_sum() * winning_value)

-- A basic test of the first board from file
-- tb = board_arr[1]
-- tb.new_called_number(5)
-- tb.new_called_number(10)
-- print(tb.new_called_number(69))
-- print(tb.new_called_number(57))
-- tb.new_called_number(63)
-- tb.new_called_number(64)
-- tb.new_called_number(59)
-- print(tb.new_called_number(74))
-- print(tb.new_called_number(50))
