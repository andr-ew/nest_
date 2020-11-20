function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
tab = require 'tabutil'

n = nest_ {
    _key.option {
        n = { 2, 3 },
        --n = 2,
        options = { 'a', 'b', 'c' },
        --wrap = true,
        --edge = 0,
        action = function(s, v, t) 
            --print('v') 
            print('v', v)
            print('t', t)
            --tab.print(v) 
        end
    }
} :connect { key = key, enc = enc }
