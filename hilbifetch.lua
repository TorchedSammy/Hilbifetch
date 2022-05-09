#!/bin/hilbish
local lunacolors = require 'lunacolors'
local hilbifetch = {
	order = {
		{'title', showName = false},
		{'infosep', showName = false},
		'os',
		'kernel',
		'uptime',
		'terminal',
		'shell',
		{'padding', showName = false},
		{'colors', showName = false}
	}
}
local infotable = {}
local displayName = {}

-- ASCII art
hilbifetch.ascii =
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
hilbifetch.sep = ' > '

function hilbifetch.addInfo(name, cb)
	infotable[name] = cb
end

function hilbifetch.getInfo(name)
	return infotable[name]()
end

function hilbifetch.setDisplay(name, display)
	displayName[name] = display
end

function hilbifetch.getDisplay(name)
	return displayName[name]
end

hilbifetch.addInfo('title', function()
	return string.format('%s@%s', hilbish.user, hilbish.host)
end)

hilbifetch.addInfo('infosep', function()
	local title = hilbifetch.getInfo 'title'
	return string.rep('~', title:len() + 1)
end)

hilbifetch.addInfo('colors', function()
	local r = '\27[49m'
	local result = {'', ''}

	for i = 0, 7 do
		result[1] = result[1] .. '\27[4' .. i .. 'm   '
	end

	result[1] = result[1] .. r

	for i = 0, 7 do
		result[2] = result[2] .. '\27[10' .. i .. 'm   '
	end

	result[2] = result[2] .. r

	return result
end)

hilbifetch.addInfo('os', function()
	return hilbish.os.name
end)

hilbifetch.addInfo('kernel', function()
	local f = io.open '/proc/version'
	local content = f:read '*a'
	f:close()

	local kernel = content:split(' ')[3]:split('-')[1]
	return kernel
end)

hilbifetch.addInfo('uptime', function()
	local _, upout = hilbish.run('uptime -p', false)

	-- (temporary) workaround for the `up` removal; an empty string doesnt work ??
	local uptime = upout:gsub('\n', ''):gsub('up ', '\0')
	return uptime
end)

hilbifetch.addInfo('shell', function()
	local shellbin = os.getenv 'SHELL'
	local _, out = hilbish.run(shellbin .. ' -v', false)

	return out:gsub('\n', '')
end)

hilbifetch.addInfo('memory', function()
	local f = io.open('/proc/meminfo', 'rb')
	local meminfo = f:read '*a'
	local memTotal, usedMem
	if meminfo then
		memTotal = meminfo:sub(select(1, meminfo:find 'MemTotal:' ), -1)
		memTotal = memTotal:sub(1, select(2, memTotal:find '\n'))
		:gsub('MemTotal:%s+', '')
			:gsub(' kB\n', '')

		p = io.popen 'free | grep Mem'
		usedMem = p:read '*a'
		usedMem = usedMem:gsub('[%a%p]+%s+%d+%s+', '')

		local i, j = usedMem:find '%d+'
		usedMem = usedMem:sub(i, j)
	else
		memTotal = 0
		usedMem = 0
	end

	f:close()

	return string.format('%.0f/%.0fMiB', tonumber(usedMem) / 1024, tonumber(memTotal) / 1024)
end)

hilbifetch.addInfo('padding', function()
	local amount

	for i, v in ipairs(hilbifetch.order) do
		local entry = type(v) == 'table' and v[1] or v

		if entry == 'padding' then
			amount = #hilbifetch.ascii:split('\n') - i - 1
		end
	end

	return string.rep(' ', amount < 0 and 0 or amount):split(' ')
end)

hilbifetch.addInfo('terminal', function()
	return os.getenv 'TERM'
end)

function longest(arr)
	local longestint = 0
	local longestidx = 1
	for i = 1, #arr do
		if utf8.len(arr[i]) > longestint then
			longestint, longestidx = utf8.len(arr[i]), i
		end
	end

	return longestidx, longestint
end

function hilbifetch.echo()
	local asciiArr = string.split(hilbifetch.ascii, '\n')
	for i, _ in ipairs(asciiArr) do
		asciiArr[i] = asciiArr[i]:gsub('^%s*(.-)$', '%1')
	end
	local _, len = longest(asciiArr)

	local done = false
	local idx = 0
	local infos = {}

	for i, _ in ipairs(hilbifetch.order) do
		local infPiece = hilbifetch.order[i]
		local infoKey = infPiece
		if type(infPiece) == 'table' then
			infoKey = infPiece[1]
		else
			infPiece = {}
		end

		local inf = hilbifetch.getInfo(infoKey)
		local display = hilbifetch.getDisplay(infoKey)
		local infName = display or infoKey
		local infFormat = ''
		if infPiece.showName ~= false then
			infFormat = infName .. hilbifetch.sep
		end
		if type(inf) == 'table' then
			for j, v in ipairs(inf) do
				if j == 1 then
					infFormat = infFormat .. v
				else
					infFormat = v
				end
				table.insert(infos, infFormat)
			end
		else
			table.insert(infos, infFormat .. inf)
		end
	end

	while not done do
		local infoPart = ''

		idx = idx + 1
		local asciiPart = asciiArr[idx]
		local spacecount = len + 3
		if asciiPart then
			infoPart = asciiPart
			spacecount = len - utf8.len(asciiPart) + 3
		end

		local info = infos[idx]
		if info then
			infoPart = infoPart .. string.rep(' ', spacecount) .. info
		end

		infoPart = infoPart .. '\n'
		if infoPart == '\n' then
			done = true
		end

		io.write(infoPart)
		io.flush()
	end
end

hilbifetch.echo()
