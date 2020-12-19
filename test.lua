function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/arc'

tab = require 'tabutil'

n = nest_ {
    f = _arc.number {
        n = 4,
        sens = 1/4,
        --range = { 0, 1.25 },
        wrap = true,
        --range = { -math.huge, math.huge },
        action = function(s, v) print(v) end
    }
} :connect({ a = arc.connect() }, 120)
