function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/arc'

tab = require 'tabutil'

g = nest_ {
    _grid.toggle {
        x = { 1, 3 },
        y = 1,
        level = { 4, 15 },
        en = true,
        action = function(s,v) print(v) end
    }
} :connect { g = grid.connect() }

function init() 
    g:init() 
end

function cleanup()
end
--]]

--[[
n = nest_ {
    a = _affordance {
        input = _input()
    }
}
--]]
