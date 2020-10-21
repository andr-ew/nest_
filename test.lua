function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/norns'
tab = require 'tabutil'

include 'lib/nest_/grid'

n = nest_ {
    v = _grid.trigger {
        x = { 1, 16 },
        y = { 1, 8 },
        edge = 0,
        action = function(s, v, t, t2, l) if l then print(#l) end end
    }
} :connect { g = grid.connect() }
