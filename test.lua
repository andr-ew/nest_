function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

tab = require 'tabutil'

n = nest_ {
    t = _grid.toggle {
        x = { 1, 16 },
        y = { 1, 8 },
        --x = 1, 
        --y = 1,
        include = { 1, 4 },
        lvl = { 
            0, 
            4,
            function(self, draw)
                while true do
                    draw(15)
                    clock.sleep(0.5)
                    draw(4)
                    clock.sleep(0.5)
                end
            end,
            function(self, draw)
                while true do
                    draw(15)
                    clock.sleep(0.1)
                    draw(4)
                    clock.sleep(0.1)
                    draw(15)
                    clock.sleep(0.1)
                    draw(0)
                    clock.sleep(0.6)
                end
            end
        },
        action = function(self, value) 
            print(self.k, value)
        end
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
