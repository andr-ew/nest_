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
        pager = _enc.txt.radio:new {
            list = { 1, 2, 3, 4 }
            x = { 8, 120 },
            y = { 8, 9 }
            n = 1
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
                            y = y * 24 + 16
                        }:link(function() return n.grid.pages.rows[x + 1 + (x * y * 2)] end)
                    end)
                end)
            }
        end)
    }
}:connect { g = grid.connect() }

-----------------------

-- grid keyboard + screen synth params with a preset selector

scale = { "D", "E", "G", "A", "B" }

n = nest_:new {
    pre = _grid.preset:new { x = { 1, 8 }, y = 1, target = function() return n.param end },
    param = {
        bend = _enc.txt.number:new {
            x = 10, y = 10, n = 2,
            action = function(s, v) engine.bend(v) end
        },
        cutoff = _enc.txt.number:new {
            x = 64, y = 10, n = 2, v = 0.7,
            action = function(s, v) 
                engine.cutoff(util.linexp(0, 1, 1, 12000, v))
            end
        }
    },
    keyboard = _grid.momentary:new {
        x = { 1, 8 }, y = { 2, 7 },
        action = function(s, v, added, removed) 
            local key
            local gate
            
            if added then
                key = added
                gate = true
            elseif removed then
                key = removed
                gate = false
            end
            
            if key then
                local note = scale[((key - 1) % #scale) + 1]
              
                for j,v in ipairs(musicutil.NOTE_NAMES) do
                    if v == note then
                        note = j - 1
                        break
                    end
                end
                  
                note = note + math.floor((key - 1) / #scale) * 12 + s.y -- add row offset and wrap scale to next octave
                  
                if gate then
                    engine.noteOn(note, musicutil.note_num_to_freq(note), 0.8 + math.random() * 0.2)
                else
                    msh.noteOff(note)
                end
            end
        end
    }
}:connect { g = grid.connect() }


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
