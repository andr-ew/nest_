function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
tab = require 'tabutil'

include 'lib/nest_/grid'

n = nest_ {
    c = _control {
        value = 5
    }
} :connect { g = grid.connect() }
