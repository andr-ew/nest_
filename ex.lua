-- 16 pages of grid toggles and faders using library controls, fader values drawn on screen

n = nest_:new {
    grid = {
        pager = _grid.value:new {
            x = { 1, 16 },
            y = 1
        },
        pages = nest_:new(1, 16):each(function(i)
            return { 
                enabled = function() 
                    return n.grid.pager() == i 
                end,
                rows = nest_:new(2, 5):each(function(i)
                    return {
                        fader = _grid.fader:new {
                            x = { 2, 15 },
                            y = i,
                            action = function(_, v) 
                                faderthings[_.y](v)
                            end
                        },
                        toggle = _grid.toggle:new {
                            x = 1,
                            y = i
                            action = function(_, v)
                                togglethings[_.y](v)
                            end
                        }
                    }
                end)
            }
        end)
    },
    screen = {
        pager = _enc.tab:new {
            x = { 8, 120 },
            y = { 8, 9 }
            enc = 1
        },
        pages = nest_:new(1, 16):each(function(i)
            return { 
                enabled = function() 
                    return n.screen.pager() == i 
                end,
                vals = nest_:new(0, 1).each(function(y)
                    return nest_:new(0, 1).each(function(x)
                        return _screen.number:new {
                            x = x * 60 + 8,
                            y = y * 24 + 16,
                            link = function() return n.grid.pages.rows[x + 1 + (x * y * 2)] end
                        }
                    end)
                end)
            }
        end)
    }
}:connect { g = grid.connect(), screen = screen }

-----------------------

-- simple custom grid control, 2 x 2 x/y selector

n = nest_:new {
    gc = _grid.control:new {
        x = { 1, 2 }, y = { 1, 2 }, lvl = 15, v = { x = 0, y = 0 },
        handler = function(s, x, y, z)
            if z == 1 then 
                s.v = { x = x - x[1], y = y - y[1] }
                s:a(s.v)
            end
        end,
        redraw = function(_)
            s.g:led(s.x[1] + s.v.x, s.y[1] + s.v.y, s.lvl)
        end,
        action = function(s, v)
            print(s.x, s.y)
        end
    }
}:connect { g = grid.connect() }
