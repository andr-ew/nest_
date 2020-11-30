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
        --x = { 32, 96 },
        --y = { 16, 48 },
        x = 128 - 4,
        y = 32,
        --value = 'one',
        value = { 'one', 'two', 'three' },
        align = { 'right', 'bottom' },
        border = 15,
        padding = 3,
        margin = 3,
        wrap = 2,
        flow = 'x'
    }
} :connect { key = key, enc = enc, screen = screen }

