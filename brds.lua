-- dual playable CV + function generator for grid + crow

include 'lib/nest_/core'
include 'lib/nest_/txt'
include 'lib/nest_/grid'

brds = nest_:new {
    pager = _grid.value:new {
        x = { 7, 8}, y = 8
    },
    pg = nest_:new(2):each(function(i)
        return {
            enabled = function() brds.pager() == i end,
            preset = _grid.preset:new {
                x = { 2, 8 }, y = 1,
                target = function(s) return s.p.par end
            },
            par = {
                -- function generator and scale params
            },
            gate = _momentary:new {
                x = 1, y = 1, lvl = { 4, 16 },
                action = function(s, v)
                    --set crow gate        
                end
            },
            slew = _control:new { v = 0 },
            cv = _grid.control:new {
                x = { 1, 8 }, y = { 2, 7 }, lvl = { 4, 16 }, 
                v = { x = 0, y = 5 },
                input = _grid.control.input:new {
                    enabled = function() s.p.gate.raw == 0 end,
                    handler = function(self, x, y, z) 
                        s.p.gate(z)
                        if z == 1 then
                            s.v = { x = x, y = x }
                        end
                    end
                },
                glide = _grid.glide.input:new {
                    enabled = function() s.p.gate.raw == 1 end
                },
                output = _grid.control.output:new {
                    redraw = function(s) 
                        s.g:led(s.x[1] + s.v.x, s.y[1] + s.v.y, s.lvl[s.p.gate()])
                    end
                },
                action = function(s, v, t) 
                    s.p.slew = (1 + (math.random() * 0.5)) * t or 0
                    
                    --set crow slew and cv out based on scale
                end
            },
            pat = _grid.pattern:new {
                target = function(s) return s.p end -- make sure to ignore self !
                mode = 'v' -- 'v' or 'handler' (default)
            }
        }
    end)
} :connect {
    g = grid.connect(),
    screen = screen
}
