function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_'
tab = require 'tabutil'

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

-- n.v.outputs[1].control == n.m.outputs[1].control == n.m :~/

-- n.m.inputs[1].control = 5
-- n.v.inputs[1].control --> 5
-- yep, they're sharing the instance table

-- n.v.inputs[1] == n.m.inputs[1] ............ lol
