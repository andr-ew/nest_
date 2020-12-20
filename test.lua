function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/arc'

tab = require 'tabutil'

n = nest_ {
    f = _arc.control {
        n = 4,
        sens = 1/2,
        controlspec = controlspec.BIPOLAR,
        action = function(s, v) print(v) end
    }
} :connect({ a = arc.connect() }, 120)
