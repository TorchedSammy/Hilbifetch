<div align='center'>
<h1>Hilbifetch</h1>
<blockquote>Simple and small fetch written in Lua.</blockquote>
</div>

<img src='preview.png' align='center'>

Hilbifetch is your average system info fetch inspired by Neofetch, my own
[Bunnyfetch](https://github.com/Rosettea/Bunnyfetch) and the others.  
But this time, it's written and configured in Lua.

# Requirements
- [Hilbish](https://github.com/Rosettea/Hilbish) v0.4.0+

# Setup
> Hilbifetch is in a very early state, expect it to look weird or have odd bugs.
```sh
git clone https://github.com/Hilbis/Hilbifetch
cd Hilbifetch
sudo ./install.lua
```

To install to a different directory (like `$HOME/bin`):
```
PREFIX=/usr/local ./install.lua
```

# Usage
`hilbifetch`  

Configuration is done via the Lua file `~/.config/hilbifetch/hfconf.lua`.  
Variables that can be changed:
- `sep`: the separator between the info title and info
- `ascii`: ascii art to use in fetch
- `colors`: enable color blocks

# License
Hilbifetch is licensed under the BSD 3-Clause license.  
[Read here](LICENSE) for more info.
