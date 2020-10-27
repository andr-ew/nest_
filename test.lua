function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/norns'
tab = require 'tabutil'

include 'lib/nest_/grid'

n = nest_ {
    v = _grid.toggle {
        x = { 1, 4 },
        --y = { 1, 8 },
        y = 1,
        edge = 0,
        action = function(s, v, t, t2, add, rem, l) 
            print("v")
            tab.print(v)
            print('t')
            tab.print(t)
         end
    }
} :connect { g = grid.connect() }
