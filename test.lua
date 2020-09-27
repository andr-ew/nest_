function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_'
tab = require 'tabutil'

--[[
c = _control:new {
    v = 3,
    inputs = { _input:new() }
}

cc = c:new {
    v = 4
}
]]

---[[
_grid = include 'lib/nest_grid'

n = nest_:new {
    v = _grid.value:new {
        x = { 1, 16 },
        y = 1,
        v = 1
    },
    m = _grid.momentary:new {
        x = { 1, 16 },
        y = 2,
        v = {}
    }
} :connect { g = grid.connect() }
--]]
