#!/bin/hilbish
local os = require 'os'
local fs = require 'fs' -- fs module from Hilbish

local f = io.open 'hilbifetch.lua'
local source = f:read '*a'
f:close()

local destdir = os.getenv 'DESTDIR' and os.getenv 'DESTDIR' or ''
local prefix = os.getenv 'PREFIX' and os.getenv 'PREFIX' or '/usr'
local binpath = destdir .. prefix .. '/bin'
local confpath = os.getenv 'HOME' .. '/.config/hilbifetch'

-- makes our destination directory if it doesnt exist
fs.mkdir(binpath, true)
fs.mkdir(confpath, true)

-- Copy Hilbifetch
local dest, e = io.open(binpath .. '/hilbifetch', 'w+')
assert(dest, e)

dest:write(source)
dest:close()

os.execute('chmod 755 ' .. binpath .. '/hilbifetch')
print('Installed Hilbifetch to ' .. binpath .. '/hilbifetch')

