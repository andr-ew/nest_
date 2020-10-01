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
        a = function(s, v)
            print(s.x, s.y)
        end
    }
}:connect { g = grid.connect() }

-----------------------------------

n = nest_:new {
    pager = _grid.value:new {
        x = { 1, 16 },
        y = 1
    },
    pages = {}
}:connect { g = grid.connect() }

for i = 1, 16 do
    local page = i

    n.pages[i] = {
        enabled = function(_) _.pager() == page end,
        rows = {}
    }
    
    for j = 2, 8 do 
        n.pages.rows[i] = {
            y = j,
            fader = _grid.fader:new {
                x = { 2, 15 },
                action = function(_, v) 
                    faderthings[_.y](v)
                end
            },
            toggle = _grid.toggle:new {
                x = 1,
                action = function(_, v)
                    togglethings[_.y](v)
                end
            }
        }
    end
end

-----------------------------------

n = nest_:new {
    pager = _grid.value:new {
        x = { 1, 16 },
        y = 1
    },
    pages = nest:new(1, 16):each(function(i)
        return { 
            enabled = function() return n.pager() == i end,
            rows = nest:new(2, 8).each(function(i)
                return {
                    y = j,
                    fader = _grid.fader:new {
                        x = { 2, 15 },
                        action = function(_, v) 
                            faderthings[_.y](v)
                        end
                    },
                    toggle = _grid.toggle:new {
                        x = 1,
                        action = function(_, v)
                            togglethings[_.y](v)
                        end
                    }
                }
            end)
        }
    end)
}:connect { g = grid.connect() }

------------------------------------- top-down heirchy version ... i don't think this makes a great case for it

n = nest_:new {
    grid = {
        pager = _grid.value:new {
            x = { 1, 16 },
            y = 1
        },
        pages = nest:new(1, 16).each(function(i)
            return { 
                enabled = function(_) 
                    return _.grid.pager() == i 
                end,
                rows = nest:new(2, 5).each(function(i)
                    return {
                        y = i,
                        fader = _grid.fader:new {
                            x = { 2, 15 },
                            action = function(_, v) 
                                faderthings[_.y](v)
                            end
                        },
                        toggle = _grid.toggle:new {
                            x = 1,
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
        pages = nest:new(1, 16).each(function(i)
            return { 
                enabled = function(_) 
                    return _.screen.pager() == i 
                end,
                vals = nest:new(0, 1).each(function(y)
                    return news:new(0, 1).each(function(x)
                        return _screen.number.output:new {
                            x = x * 60 + 8,
                            y = y * 24 + 16,
                        }:each(function(i, _) 
                            _.grid.pages.rows[x + 1 + (x * y * 2)]:append(_)
                        end)
                    end)
                end)
            }
        end)
    }
}:connect { g = grid.connect() }

-----------------------------------

n = nest_:new {
    grid = {
        pager = _grid.value:new {
            x = { 1, 16 },
            y = 1
        },
        pages = {}
    },
    screen = {
        pager = _enc.tab:new {
            x = { 8, 120 },
            y = { 8, 9 },
            enc = 1
        },
        pages = {}
    }
}:connect { g = grid.connect() }

for i = 1, 16 do
    local page = i

    n.grid.pages[i] = {
        enabled = function() grid.pager() == page end,
        rows = {}
    }
    
    for j = 2, 5 do 
        n.pages.rows[i] = {
            fader = _grid.fader:new {
                x = { 2, 15 },
                y = j,
                action = function(_, v) 
                    faderthings[_.y](v)
                end
            },
            toggle = _grid.toggle:new {
                x = 1,
                y = j,
                action = function(_, v)
                    togglethings[_.y](v)
                end
            }
        }
    end
    
    n.screen.pages[i] = {
        enabled = function() screen.pager() == page end,
        grid = {}
    }

    for x = 0, 1 do
        n.screen.pages[y].grid = {}
        for y = 0, 1 do
            n.screen.pages[i].grid[x][y] = _screen.number.output:new {
                x = x * 60 + 8,
                y = y * 24 + 16
            }

            n.grid.pages.rows[x + 1 + (x * y * 2)]:append(n.screen.pages[i].grid[x][y])
        end
    end
end

----------------------------------- this doesn't use _meta or top down stuff, if we call the :each function after initilization "absolute paths" can be used and things stay pretty clean. this makes a case for possibly removing _meta altogether

n = nest_:new {
    grid = {
        pager = _grid.value:new {
            x = { 1, 16 },
            y = 1
        },
        pages = nest:new(1, 16):each(function(i)
            return { 
                enabled = function() 
                    return n.grid.pager() == i 
                end,
                rows = nest:new(2, 5):each(function(i)
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
        pages = nest:new(1, 16):each(function(i)
            return { 
                enabled = function() 
                    return n.screen.pager() == i 
                end,
                vals = nest:new(0, 1).each(function(y)
                    return news:new(0, 1).each(function(x)
                        return _screen.number.output:new {
                            x = x * 60 + 8,
                            y = y * 24 + 16,
                        }:each(function(i, _) 
                            n.grid.pages.rows[x + 1 + (x * y * 2)]:append(_) 
                        end)
                    end)
                end)
            }
        end)
    }
}:connect { g = grid.connect() }
