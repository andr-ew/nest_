function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

tab = require 'tabutil'

n = nest_ {
    m = _grid.momentary {
        x = { 2, 6 },
        y = { 3, 5 },
        lvl = { 4, 15 },
        action = function(self, value)
            print('momentary')
        end
    },
    t = _grid.pattern {
        x = 2, y = 6,
    }
} :connect { g = grid.connect() }

--[[

    t = _grid.toggle {
        x = 1,
        y = 1,
        lvl = { 
            0, 
            function(self, draw)
                while true do
                    draw(15)
                    clock.sleep(0.1)
                    draw(4)
                    clock.sleep(0.1)
                    draw(15)
                    clock.sleep(0.1)
                    draw(4)
                    clock.sleep(0.6)
                end
            end
        },
        action = function(self, value) 
            print(self.k, value)
        end
    }

--]]
