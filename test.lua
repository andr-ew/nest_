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
    ---[[
    t = _grid.pattern {
        x = { 2, 6 }, y = 6,
        count = 1,
        target = function() return n.m end
    }
    --]]
    --[[
    t = _grid.toggle {
        x = { 2, 6 }, y = 6,
        lvl = { 0, 4, 15 },
        include = { 1, 2 },
        count = 1
    }
    --]]
    --[[
    t = _grid.toggle {
        x = { 2, 6 }, y = 6,
        lvl = {
        0, ------------------ 0 empty
        function(s, d) ------ 1 empty, recording, no playback
            while true do
                d(4)
                clock.sleep(0.25)
                d(0)
                clock.sleep(0.25)
            end
        end,
        15, ----------------- 2 filled, playback
        },
        count = 1
        --target = function() return n.m end
    }
    --]]
} :connect { g = grid.connect() }

function init() n:init() end

--[[
    t = _grid.pattern {
        x = { 2, 6 }, y = 6,
        target = function() return n.m end
    }

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
