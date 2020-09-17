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

_grid.t = _control:new()
_grid.t.inputs[1] = _input:new()
print("deviceidx: ", _grid.t.inputs[1] and _grid.t.inputs[1]._.deviceidx or "nil index")
