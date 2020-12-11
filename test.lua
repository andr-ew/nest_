function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/txt'

tab = require 'tabutil'

--test n = { 2, 3 }
n = nest_ {
    num = _txt.label {
        value = {
            { 'foo', 'bar', 'ding', 'bat' },
            { 'bar', 'foo', 'bat', 'ding' },
            { 'bat', 'ding', 'bar', 'foo' }
        },
        flow = 'y',
        lvl = { 2, 15 },
        selected = { { x = 2, y = 1 }, { x = 3, y = 2 } }
    }
} :connect { key = key, enc = enc, screen = screen }  
