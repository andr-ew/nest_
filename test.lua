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
    o = _txt.enc.option {
        ---[[    
        options = { 'foo', 'bar', 'ding', 'bat', 'foo', 'bar', 'ding', 'bat' },
        flow = 'y',
        scroll_window = 1,
        test = "foobar",
        --action = function(s, v, option) print(v, option) end
        --]]
        --[[
        x = 12,
        y = 12,
        n = { 2, 1 },
        flow = 'y',
        size = 10,
        margin = 0, 
        padding = 3,
        lvl = 15,
        border = { 0, 15 },
        options = { 
            { 'a', 'b', 'c' },
            { 'd', 'e', 'f' },
            { 'h', 'i', 'j' }
        },
        action = function(s, v, o) print(o) end
        --]]
    }
} :connect { key = key, enc = enc, screen = screen }  
