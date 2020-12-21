function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/arc'

tab = require 'tabutil'

n = nest_ {
    f = _arc.option {
        x = { 42, 24 },
        n = 4,
        sens = 1/16,
        size = { 1, 2, 4, 8 },
        margin = 0,
        lvl = { 0, 4, 15 },
        action = function(s, v) print(v) end
    }
} :connect({ a = arc.connect() }, 120)
