<div align='center'>
<h1>Hilbifetch</h1>
<blockquote>Simple and small fetch written in Lua.</blockquote>
</div>

<img src='preview.png' align='center'>

Hilbifetch is your average system info fetch inspired by Neofetch, my own
[Bunnyfetch](https://github.com/Rosettea/Bunnyfetch) and the others.  
But this time, it's written and configured in Lua.

# Requirements
- [Hilbish](https://github.com/Rosettea/Hilbish) master branch

# Setup
> Hilbifetch is in a very early state, expect it to look weird or have odd bugs.
```sh
git clone https://github.com/TorchedSammy/Hilbifetch
cd Hilbifetch
sudo ./install.lua
```

To install to a different directory (like `$HOME/bin`):
```
PREFIX=/usr/local ./install.lua
```

# Usage
`hilbifetch` (or `./hilbifetch.lua`)  

Configuration is done via the Lua file `~/.config/hilbifetch/init.lua`.  
There are a few functions and variables available. They are all accessed
via the global `hilbifetch` table.

- `sep`: Separator used for info.
- `ascii`: ASCII art.
- `order`: A table describing the order of info. The format for keys is either
a string of an info name or a table with the first entry being the name and other
options. Example:
```lua
hilbifetch.order = {
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
```
This is the default order of info. The options available for info are:
`showName` - Whether to show the display name.
`color` - Color of the info text.
`nameColor` - Color of the display name.

- `addInfo(name, callback)`: adds info with `name`.
- `getInfo(name)`: gets info from `name`
- `setDisplay(name)`: sets the display name of `name`d info. if the display
name isn't set, it'll use the normal name instead.
- `getDisplay(name)`: gets the display name of the `name`d info.

# License
Hilbifetch is licensed under the BSD 3-Clause license.  
[Read here](LICENSE) for more info.
