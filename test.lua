function r()
  norns.script.load(norns.state.script)
end

include 'lib/nest_'
_grid = include 'lib/nest_grid'

n = nest_:new {
    _meta = { foo = 'bar' },
    --welp, this is very wrong, new inheritance model maybe will fix hehe
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

cc = _cat_:new {
    a = 1,
    b = { 'ep', 'bo' }
}

ccc = cc:new {
    c = 4
}
