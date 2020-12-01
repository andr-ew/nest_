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
        x = { { 4, 24 }, { 28, 48 }, { 52, 72 }, { 80, 126 } },
        --y = { { 2, 24 }, { 32, 44 }, { 4, 20 }, { 40, 62 } },
        --x = { { 4 }, { 28 }, { 52 }, { 107 } },
        --y = { { 2 }, { 32 }, { 4 }, { 40 } },
        --y = { 8, 32 },
        y = { 2, 12 },
        value = { 'foo', 'bar', 'ding', 'bat' },
        border = 15,
        padding = 3,
        margin = 3,
        flow = 'x'
    }
} :connect { key = key, enc = enc, screen = screen }
