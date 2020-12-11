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
    num = _txt.enc.option {
        options = { 'a', 'b', 'c' },
        action = function(s, v) --tab.print(v) 
        end
    }
} :connect { key = key, enc = enc, screen = screen }  
