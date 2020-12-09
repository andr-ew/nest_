function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/txt'

tab = require 'tabutil'

n = nest_ {
    _txt.label {
        y = 4,
        --y = { 2, 62 },
        ---[[
        x = {
            { { 4 }, { 28 }, { 52 }, { 90 } },
            { { 4 }, { 28 }, { 52 }, { 80 } },
            { { 4 }, { 28 }, { 52 }, { 80 } }
        },
        --]]
        ---[[
        value = { 
            { 'f', 'b', 'd', 'b' },
            { 'b', 'f', 'b', 'd' },
            { 'b', 'd', 'b', 'f' }
        },
        --]]
        --x = { 2, 126 },
        --x = 126,
        --align = { 'right', 'top' },
        --value = { 'a', 'b', 'c', 'd' },
        border = 15,
        padding = 3,
        margin = 3,
        flow = 'y',
        size = 10,
        --size = { 20, 'auto' }
    }
} :connect { key = key, enc = enc, screen = screen }
