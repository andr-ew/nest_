function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_'
tab = require 'tabutil'

--[[
c = _control:new {
    v = { 1, 2 },
    input = _input:new()
}

cc = c:new()
]]

_grid = include 'lib/nest_grid'

n = nest_:new {
    v = _grid.value:new {
        x = { 1, 2 },
        y = 1,
        v = 1
    },
    m = _grid.momentary:new {
        x = { 3, 4 },
        y = 1,
        v = {}
    }
} :connect { g = grid.connect() }

-- n.v.output.v ~= n.v.v
