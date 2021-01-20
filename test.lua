function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

tab = require 'tabutil'

---[[
g = nest_ {
    n = _grid.number {
        x = { 1, 8 }, y = function() return 1 end,
        action = function(s, v)
            print(v)
        end
    }
} :connect { g = grid.connect() }

function init() g:init() end
--]]

--[[
n = nest_ {
    a = _affordance {
        input = _input()
    }
}
--]]
