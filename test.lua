function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
tab = require 'tabutil'

n = nest_ {
    _key.momentary {
        n = 2,
        action = function(s, v, t) print(v, t) end
    }
} :connect { key = key, enc = enc }
