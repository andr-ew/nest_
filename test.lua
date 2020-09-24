function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_'
tab = require 'tabutil'

c = _control:new {
    v = { 1, 2 }
    , inputs = { _input:new { foo = "bar" } }
}

cc = c:new() -- stack overflow, only when c.inputs[1] is present

--_grid = include 'lib/nest_grid'

--[[
n = nest_:new {
    --welp, this is very wrong, new inheritance model maybe will fix hehe
    v = _grid.value:new {
        x = { 1, 2 },
        y = 1,
        v = 0
    },
    m = _grid.momentary:new {
        x = { 3, 4 },
        y = 1,
        v = {}
    }
} :connect { g = grid.connect() } 
]]
