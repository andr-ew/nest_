function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/arc'

tab = require 'tabutil'

n = nest_ {
    f = _arc.fill {
        v = { 1/6, 5/6 },
        n = 1
    }
} :connect { a = arc.connect() }  
