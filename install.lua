#!/bin/hilbish
local os = require 'os'
local fs = require 'fs' -- fs module from Hilbish

local f = io.open 'hilbifetch.lua'
local cf = io.open 'hfconf.lua'
local source = f:read '*a'
local confsource = cf:read '*a'
f:close()
cf:close()

local destdir = os.getenv 'DESTDIR' and os.getenv 'DESTDIR' or ''
local prefix = os.getenv 'PREFIX' and os.getenv 'PREFIX' or '/usr'
local binpath = destdir .. prefix .. '/bin'
local confpath = os.getenv 'HOME' .. '/.config/hilbifetch'

-- makes our destination directory if it doesnt exist
fs.mkdir(binpath, true)
fs.mkdir(confpath, true)

-- Copy config
local confdest, e = io.open(confpath .. '/hfconf.lua', 'w+')
assert(confdest, e)

confdest:write(confsource)
confdest:close()

-- And Hilbifetch itself
local dest, e = io.open(binpath .. '/hilbifetch', 'w+')
assert(dest, e)

dest:write(source)
dest:close()

os.execute('chmod 755 ' .. binpath .. '/hilbifetch')
print('Installed Hilbifetch to ' .. binpath .. '/hilbifetch')

