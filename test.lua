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
        x = 64,
        y = 32,
        align = { 'center', 'center' },
        value = 'peepee',
        border = 7,
        font = 1,
        --size = 16,
        padding = 3
    }
} :connect { key = key, enc = enc, screen = screen }

