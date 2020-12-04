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
        x = 4,
        value = { 
            { 'foo', 'bar', 'ding', 'bat' },
            { 'bar', 'foo', 'bat', 'ding' },
            { 'bat', 'ding', 'bar', 'foo' }
        },
        border = 15,
        padding = 3,
        margin = 3,
        flow = 'y'
    }
} :connect { key = key, enc = enc, screen = screen }
