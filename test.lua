function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/norns'
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

include 'lib/nest_/grid'

n = nest_:new {
    v = _grid.value:new {
        z = 2,
        x = function() return { 1, 16 } end,
        y = 1,
        action = function(s, v) print(v) end
    },
    m = _grid.momentary:new {
        z = 3,
        x = { 1, 16 },
        y = { 2, 7 },
        action = function(s, v) print(v) end
    },
    f = _grid.fill:new {
        z = 1,
        x = { 1, 16 },
        y = 8
    }
} :connect { g = grid.connect() }
