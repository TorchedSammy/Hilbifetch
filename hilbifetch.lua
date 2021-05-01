local ansikit = require 'ansikit'
local infotable = {}
local infoidx = {}

-- ASCII art
local ascii =
[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣐⣶⣶⣀⡀⣤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣠⣴⣖⢶⣶⣦⣀⢰⣿⣿⣿⣿⠏⠀⠀⣐⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣸⣿⣿⣿⣯⣻⣿⣿⢹⣿⣿⣿⡟⠠⠨⠪⠂⣰⣦⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⢯⣶⣮⢿⣿⣷⡽⣿⡘⣿⡿⣿⠁⡑⠡⠃⣰⣿⣿⣿⣦⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠉⠑⠛⢿⣿⣿⣇⣿⠇⠁⡐⠀⢀⣬⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⣴⣶⣴⣽⢿⣯⠸⡀⡐⠀⠐⢱⣙⣮⣭⣿⣿⠿⠷⠀⠀⠀⠀
⠀⠀⠀⠀⣠⣻⣿⠿⣿⣿⣟⣩⡑⠀⢠⠁⠀⠮⠿⠶⠶⠦⣌⡁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢈⣿⣿⣿⣿⣷⣿⣿⢟⣍⣤⣨⡴⣄⢎⢍⡖⡿⠽⣿⣟⣷⣄⠀⠀⠀⠀
⠀⠀⠀⠸⣿⣿⣿⣿⢿⣯⣮⣟⣾⣿⠋⠘⠉⠑⣳⡻⣦⣯⣽⣿⣿⣿⡀⠀⠀⠀
⠀⠀⠀⠀⠘⢿⣷⣽⣿⡿⡎⠛⠋⠁⠀⠀⠀⠀⢳⢿⣽⣷⣿⣝⢿⡿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠉⠙⠻⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣽⣾⡿⠟⠁⠀⠀⠀⠀]]

-- Utility Functions
function string.split(str, delimiter)
	local result = {}
	local from = 1
	
	local delim_from, delim_to = string.find(str, delimiter, from)
	
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from)
	end
	
	table.insert(result, string.sub(str, from))

	return result
end

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
function info(tbl)
	local i = 1
	for k, v in pairs(tbl) do
		local function _infofunc()
			if k == "os" then
				-- Should always exist on unix
				local f = io.open("/etc/os-release", "rb")
				local content = f:read '*a'
				f:close()

				local os = string.split(content, "\n")[1]
				os = string.split(os, "=")[2]:gsub("\"", "")
				return os
			elseif k == "kernel" then
				local f = io.popen 'uname -r'
				local content = f:read '*a'
				f:close()

				local kernel = content:split("-")[1]
				return kernel
			elseif k == "uptime" then
				local f = io.popen 'uptime -p'
				local upout = f:read '*a'
				f:close()

				local uptime = upout:gsub("up ", ""):gsub('\n', '')
				return uptime
			end
		end
		infotable[k] = {name = v, infofunc = _infofunc}
		infoidx[i] = k
		i = i + 1
	end
end

dofile 'config.lua'

-- Hilbifetch - Where we actually print our info
local asciiarr = string.split(ascii, "\n")
local _, len = longest(asciiarr)

for i = 1, #asciiarr do
	asciipart = asciiarr[i]
	local infotbl = infotable[infoidx[i]]
	local infoname = nil
	local inf = nil
	local fullinfo = ""
	if infotbl ~= nil then
		infoname = infotbl['name']
		inf = infotbl['infofunc']()
		fullinfo = ansikit.format('{bold}{blue}' .. infoname .. '{reset}') .. ' > ' .. inf
	end
	local spacecount = len - string.len(asciipart)
	print(asciipart .. string.rep(" ", spacecount) .. fullinfo)
end

