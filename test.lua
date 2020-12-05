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
        x = {
            { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 90, 126 } },
            { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 80, 126 } },
            { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 80, 126 } }
        },
        value = { 
            { 'foo', 'bar', 'ding', 'bat' },
            { 'bar', 'foo', 'bat', 'ding' },
            { 'bat', 'ding', 'bar', 'foo' }
        },
        border = 15,
        padding = 3,
        margin = 3,
        flow = 'y'
        --cellsize = { 10, 10 }
    }
} :connect { key = key, enc = enc, screen = screen }
