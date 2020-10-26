function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/norns'
tab = require 'tabutil'

include 'lib/nest_/grid'

n = nest_ {
    v = _grid.fader {
        x = { 1, 7 },
        y = { 1, 7 },
        --y = 1,
        range = { -1, 1 },
        action = function(s, v, t, t2, add, rem, l) print('v', v, "t", t, "d", t2) end
    }
} :connect { g = grid.connect() }
