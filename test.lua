function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/txt'

tab = require 'tabutil'

n = nest_ {
    _txt.enc.number {
        n = 2,
        range = { 0, 10 },
        action = function(s, v) print(v) end
    }
} :connect { key = key, enc = enc, screen = screen }  
