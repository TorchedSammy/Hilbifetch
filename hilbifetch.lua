#!/bin/hilbish
local lunacolors = require 'lunacolors'
local infotable = {}
local infoidx = {}

-- ASCII art
ascii =
[[  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣐⣶⣶⣀⡀⣤⠄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣠⣴⣖⢶⣶⣦⣀⢰⣿⣿⣿⣿⠏⠀⠀⣐⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣸⣿⣿⣿⣯⣻⣿⣿⢹⣿⣿⣿⡟⠠⠨⠪⠂⣰⣦⣄⠀⠀⠀
⠀⠀⠀⢠⢯⣶⣮⢿⣿⣷⡽⣿⡘⣿⡿⣿⠁⡑⠡⠃⣰⣿⣿⣿⣦⠀⠀
⠀⠀⠀⠀⠀⠈⠉⠑⠛⢿⣿⣿⣇⣿⠇⠁⡐⠀⢀⣬⣿⣿⣿⣿⣿⡄⠀
⠀⠀⠀⠀⠀⠀⣠⣴⣶⣴⣽⢿⣯⠸⡀⡐⠀⠐⢱⣙⣮⣭⣿⣿⠿⠷⠀
⠀⠀⠀⠀⣠⣻⣿⠿⣿⣿⣟⣩⡑⠀⢠⠁⠀⠮⠿⠶⠶⠦⣌⡁⠀⠀⠀
⠀⠀⠀⢈⣿⣿⣿⣿⣷⣿⣿⢟⣍⣤⣨⡴⣄⢎⢍⡖⡿⠽⣿⣟⣷⣄⠀
⠀⠀⠀⠸⣿⣿⣿⣿⢿⣯⣮⣟⣾⣿⠋⠘⠉⠑⣳⡻⣦⣯⣽⣿⣿⣿⡀
⠀⠀⠀⠀⠘⢿⣷⣽⣿⡿⡎⠛⠋⠁⠀⠀⠀⠀⢳⢿⣽⣷⣿⣝⢿⡿⠀
⠀⠀⠀⠀⠀⠀⠉⠙⠻⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣽⣾⡿⠟⠁⠀]]

function longest(arr)
	local longestint = 0
	local longestidx = 1
	for i = 1, #arr do
		if string.len(arr[i]) > longestint then
			longestint, longestidx = string.len(arr[i]), i
		end
	end

	return longestidx, longestint
end

-- For config.lua
-- Title and info separator
sep = ' > '
colors = true

-- Color function to print colors
function colors()
	local r = '\27[49m'
	local result = {'', ''}

	for i=0,7 do
		result[1] = result[1] .. '\27[4' .. i .. 'm   '
	end

	result[1] = result[1] .. r

	for i=0,7 do
		result[2] = result[2] .. '\27[10' .. i .. 'm   '
	end
	
	result[2] = result[2] .. r
	
	return result
end

-- Info function to declare what to output
function info(tbl)
	local i = 1
	for k, v in pairs(tbl) do
		local function _infofunc()
			if k == 'os' then
				-- Should always exist on unix
				local f = io.open('/etc/os-release', 'rb')
				local content = f:read '*a'
				f:close()

				local os = string.split(content, '\n')[1]
				os = string.split(os, "=")[2]:gsub('"', '')
				return os
			elseif k == 'kernel' then
				local f = io.popen 'uname -r'
				local content = f:read '*a'
				f:close()

				local kernel = content:split('-')[1]
				return kernel
			elseif k == 'uptime' then
				local f = io.popen 'uptime -p'
				local upout = f:read '*a'
				f:close()

				local uptime = upout:gsub('up ', ''):gsub('\n', '')
				return uptime
			elseif k == 'terminal' then
				return os.getenv 'TERM'
			elseif k == 'shell' then
				local shellbin = os.getenv 'SHELL'
				local f = io.popen(shellbin .. ' -v')
				local sh = f:read '*a'
				f:close()

				return sh:gsub('\n', '')
			end
		end
		infotable[k] = {name = v, infofunc = _infofunc}
		infoidx[i] = k
		i = i + 1
	end
end

local ok = pcall(function()
	dofile (os.getenv 'HOME' .. '/.config/hilbifetch/hfconf.lua')
end)
if not ok then
	ok = pcall(function() dofile '/etc/hfconf.lua' end)
end
if not ok then
	pcall(function() dofile 'hfconf.lua' end)
end

-- Hilbifetch - Where we actually print our info
local asciiarr = string.split(ascii, '\n')
local _, len = longest(asciiarr)

-- Make sure we have enough space to print colors
local linecount = 2 + #infoidx + 1
if colors then linecount = linecount + 3 end
if #asciiarr < linecount then
	for i = #asciiarr, linecount - 2 do
		table.insert(asciiarr, '')
	end
end

for i = 1, #asciiarr do
	asciipart = asciiarr[i]
	local infotbl = infotable[infoidx[i - 2]]
	local infoname = nil
	local inf = nil
	local fullinfo = ''
	if i == 1 then
		username = os.getenv 'USER'

		local f = io.open('/etc/hostname', 'rb')
		hostname = f:read '*a'
		f:close()

		fullinfo = lunacolors.magenta(username .. '@' .. hostname:gsub('\n', ''))
	end
	if i == 2 then fullinfo = string.rep('~', hostname:len() + 1 + username:len()) end
	if infotbl ~= nil then
		infoname = infotbl['name']
		inf = infotbl['infofunc']()
		fullinfo = lunacolors.bold(lunacolors.blue(infoname)) .. sep  .. inf
	end

	local colorinfo = colors()
	if colors and i >= linecount - 2 then
		if i == linecount - 2 then fullinfo = colorinfo[1] end
		if i == linecount - 1 then fullinfo = colorinfo[2] end
	end

	local spacecount = len - string.len(asciipart) + 3
	print(asciipart .. string.rep(' ', spacecount) .. fullinfo)
end
