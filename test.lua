function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/txt'

tab = require 'tabutil'

--test cellsize
--maybe refactor cellsize into txtpoint instead of txtline, it probably bugs out rn
--also maybe add cellsize 'auto', because I'm crazy & we've gone this deep already

n = nest_ {
    _txt.label {
        y = 4,
        --[[
        x = {
            { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 90, 126 } },
            { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 80, 126 } },
            { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 80, 126 } }
        },
        ]]
        --[[
        value = { 
            { 'f', 'b', 'd', 'b' },
            { 'b', 'f', 'b', 'd' },
            { 'b', 'd', 'b', 'f' }
        },
        --]]
        --x = { 32, 76 },
        x = { 2, 126 },
        --x = 126,
        align = { 'right', 'top' },
        --value = { 'a', 'b', 'c', 'd' },
        value = { 'a', 'b', 'c', 'd' },
        border = 15,
        padding = 3,
        margin = 0,
        --flow = 'y',
        size = { 'auto', 20 }
    }
} :connect { key = key, enc = enc, screen = screen }
