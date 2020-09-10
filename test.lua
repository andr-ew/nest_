function r()
  norns.script.load(norns.state.script)
end

include 'lib/nest_'
_grid = include 'lib/nest_grid'

n = nest_:new {
    v = _grid.value:new {
        x = { 1, 2 },
        y = 1,
        v = 0
    }
} :connect { g = grid.connect() } 
