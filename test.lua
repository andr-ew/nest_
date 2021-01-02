function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'

tab = require 'tabutil'

n = nest_ {
    momentary_0d = _grid.momentary {
        x = 1,
        y = 3,
        lvl = { 4, 15 },
        action = function(self, value) 
            print(self.k, v) 
        end
    }, 
    momentary_1d = _grid.momentary {
        x = { 1, 7 },
        y = 5,
        lvl = { 4, 15 },
        action = function(self, value) 
            print(self.k)
            print_matrix_1d(value)
        end
    }
}
