function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
tab = require 'tabutil'

n = nest_ {
    _enc.control {
        n = { 2, 3 },
        --n = 2,
        range = { 0, 1 },
        --wrap = true,
        action = function(s, v, t) 
            print('v') 
            --print(v)
            tab.print(v) 
        end
    }
} :connect { key = key, enc = enc }
