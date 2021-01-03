function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

tab = require 'tabutil'

n = nest_ {
    m = _grid.number {
        x = { 1, 7 },
        y = 5,
        lvl = { 4, 15 },
        action = function(self, value) 
            print(self.k, value)
        end
    }
} :connect { g = grid.connect() }
