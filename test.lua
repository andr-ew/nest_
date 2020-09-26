function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_'
tab = require 'tabutil'

c = _control:new {
    v = { 1, 2 },
    input = _input:new()
}

cc = c:new()

-- c.inputs[1] == cc.inputs[1]
-- c.inputs ~= cc.inputs
-- c.inputs[1] ~= iis[1]
-- c.t.b ~= cc.t.b -- b is {} or _obj_ or _input
-- clone issue is specific to inputs[1] ???
-- swap keys 'inputs' & 't', cloning issue goes away 
-- check _control:new i/o loop

--[[
_grid = include 'lib/nest_grid'

n = nest_:new {
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
-- n.v.outputs[1].control == n.m.outputs[1].control == n.m :~/

-- n.m.inputs[1].control = 5
-- n.v.inputs[1].control --> 5
-- yep, they're sharing the instance table

-- n.v.inputs[1] == n.m.inputs[1] == _grid.value.inputs[1] == _grid.control.inputs[1] ............ lol
