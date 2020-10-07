-- dual playable CV + function generator for grid + crow

include 'lib/nest_/norns'
include 'lib/nest_/txt'
include 'lib/nest_/grid'

brds = nest_:new {
    pager = _grid.value:new {
        x = { 7, 8}, y = 8
    },
    pg = nest_:new(2):each(function(i)
        return {
            enabled = function() brds.pager() + 1 == i end,
            func_pre = _grid.preset:new {
                x = { 2, 8 }, y = 1,
                target = function(s) return s.p.func end,
                action = function(s, v) 
                    _grid.preset.action(s, v)
                    s.p.func.enabled = true
                    s.p.quant.enabled = false
                end
            },
            func = {
                enabled = true
                -- time
                -- ramp
                -- curve
                -- transient/sustain/cycle
            },
            trans = _grid.glide:new {
                x = { 1, 4}, y = 2,
                action = function(s, v, t)
                    -- set crow slew
                    s.p.cv()
                end
            },
            quant_pre = _grid.preset:new {
                x = { 4, 8 }, y = 2,
                target = function(s) return s.p.scale end,
                action = function(s, v) 
                    _grid.preset.action(s, v)
                    s.p.quant.enabled = true
                    s.p.func.enabled = false
                end
            },
            quant = {
                enabled = false
                --[[
                
                root: (440)
                scale: 24tet/(ji)/linear
                tuning: +1 ... 3.5 .. 12 (semitones, 0.5 is quarter tone)
                key:

                 c# d#    f# g# a#
                c  d  e  f  g  a  b

                  #   #     #   #   #
                 # # # # # # # # # # # #
                c   d   e f   g   a   b
               
                make 24tet the defacto ? :)
 
                ]]
            },
            tgl = _momentary:new {
                x = 1, y = 1, lvl = { 4, 16 },
                action = function(s, v)
                    --set crow trig/gate/loop based on function mode
                end
            },
            cv = _grid.control:new {
                x = { 1, 8 }, y = { 2, 7 }, lvl = { 4, 16 }, 
                v = { x = 0, y = 5 },
                input = _grid.control.input:new {
                    enabled = function() s.p.gate.raw == 0 end,
                    handler = function(self, x, y, z) 
                        s.p.tgl(z)
                        if z == 1 then
                            s.v = { x = x, y = x }
                        end
                    end
                },
                glide = _grid.glide.input:new {
                    enabled = function() s.p.tgl.raw == 1 end
                },
                output = _grid.control.output:new {
                    redraw = function(s) 
                        s.g:led(s.x[1] + s.v.x, s.y[1] + s.v.y, s.lvl[s.p.tgl.v + 1])
                    end
                },
                action = function(s, v, t) 
                    local st = (1 + (math.random() * 0.5)) * t or 0
                    
                    --set crow slew + cv out based on scale, trans
                end
            },
            pat = nest_:new(6):each(function(i) 
                return {  
                    rec = _grid.pattern:new {
                        x = i,
                        y = 8,
                        lvl = { 0, 4 },
                        limit = 1, --
                        edge = 0, ---
                        target = function(s) return s.p end, -- make sure to ignore self !
                        action = function(s, v, t) 
                            if s:play() then 
                                s.lvl = { 4, 16 }
                                s.p.pg.enabled = v == 1
                                s.p.pg.play(1)
                            elseif v == 1 and t <= 0.5 then
                                s:clear()
                            elseif v == 0 then
                                s.lvl = { 0, 4 } 
                            end

                            if not s:play() and v == 1 and t > 0.5 then
                                s.p.pg.enabled = 1
                            elseif not s:play() and v == 0 then
                                s.p.pg.enabled = 0
                            else
                                _grid.pattern.action(s, v)
                            end

                            s.p.p.cv.enabled = not s.p.pg.enabled
                        end
                    },
                    pg = {
                        enabled = false,
                        play = _grid.toggle:new {
                            x = i, y = 7,
                            action = function(s, v) 
                                s.p.rec:play(v)
                            end
                        },
                        rate = _grid.value:new {
                            x = { 1, 8 }, y = 4, v = 4,
                            action = function(s, v) s.p.rec:rate(math.pow(2, v - 4)) end
                        }
                        -- propability ?
                    }
                }
            end)
        }
    end)
} :connect {
    g = grid.connect(),
    screen = screen, 
    enc = enc, 
    key = key
}
