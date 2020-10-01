include 'lib/nest_.lua'

sc = include 'lib/supercut'

ndls = nest_:new {
    tp = nest_:new(1, 4):each(function(i)
        return {
            level = _arc.fader:new {
                ring = function() ndls.arcpg.vertical and i or 1 end,
                x = { 8, 54 },
                action = function(s, v) 
                    sc.level(i, v)
                end,
                enabled = function() return ndls.arcpg()[i][0] == 1 end
            },
            mod = {
                v = 0,
                x = 0,
                a = 0,
                y = 0,
                dt = 1/60,
                tick = function()
                    local tp = ndls.tp[i]
                    local m = tp.mod
                    m.v = m.v + m.a * m.dt
                    m.x = math.fmod(m.x + m.v * m.dt, 1)
                    m.y = -1 * math.sin(m.x * 2 * math.pi)

                    tp.arc_mod(m.x)
                end
            },
            init = function(s) s.mod.tick:start() 
                metro.init(s.mod.tick, s.mod.dt):start()
            end,
            arc_mod = _arc.cycle:new {
                ring = function() return ndls.arcpg.vertical and i or 2 end,
                handler = function(s, ring, d) -- weird use !
                    s.p.mod.v = s.p.mod.v + d 
                end,
                enabled = function() return ndls.arcpg()[i][1] == 1 and ndls.global.alt() == 1 end
            },
            start = _arc.value:new {
                ring = function() ndls.arcpg.vertical and i or 3 end, -- all params can be functions !
                x = { 0, 64 },
                action = function(s, v)
                    sc.loop_start(i, v * sc.region_length(i)) -- v is 0-1

                    s.p.length:bang() --
                    s.p.window:bang()
                    s.p.endpt:bang()
                end,
                enabled = function() return ndls.arcpg()[i][2] == 1 end
            },
            length = _arc.value:new {
                ring = function() ndls.arcpg.vertical and i or 4 end,
                x = { 1, 64 },
                action = function(s, v)
                    local len = util.clamp(v * sc.region_length(i), 0.001, 1 - s.p.start())
                    sc.loop_length(i, len)
                    
                    s.p.window:bang()
                    s.p.endpt:bang()
                    
                    return len / sc.region_length(i)
                end,
                enabled = function() return ndls.arcpg()[i][3] == 1 end,
                output = { enabled = false } --
            },
            endpt = _arc.value:new {
                ring = function() ndls.arcpg.vertical and i or 4 end,
                x = { 1, 64 },
                action = function(s) 
                    return s.p.start() + s.p.length()
                end,
                enabled = function() return ndls.arcpg()[i][3] == 1 end,
                input = { enabled = false }
            },
            window  = _arc.range:new {
                ring = function() ndls.arcpg.vertical and i or { 3, 4 } end, -- multiple rings
                lvl = 4,
                action = function(s)
                    return { s.p.start(), s.p.endpt() }
                end,
                order = -1,
                enabled = function() return ndls.arcpg()[i][2] == 1 or ndls.arcpg()[i][3] == 1 end,
            }
            buffer = _grid.value:new {
                x = { 8, 15 }, y = i + 3, v = i
                action = function(s, v)
                    sc.buffer_steal_region(i, v + 1)
                end
            }
            punchin = nil,
            resetwindow = function(s)
                s.p.start(sc.region_start(i))
                s.p.length(sc.region_length(i))
            end
            rec = _grid.toggle:new { 
                x = 1, y = i + 3,
                action = function(s, v)
                    if not s.p.play() and v == 1 then
                        sc.buffer_clear_region(i)
                        sc.buffer_steal_home_region(i, s.p.buffer())
                        s.p.resetwindow(s)
                        
                        s.p.punchin = util.time()
                    end

                    if v == 0 and s.p.punchin then
                        sc.region_length(i, punchin)
                        s.p.resetwindow(s)

                        s.p.punchin = nil
                    end
                    
                    sc.rec(i, v)
                end
            },
            play = _grid.toggle:new {
                x = 2, y = i + 3, lvl = { 4, 15 },
                action = function(s, v)
                    if v == 1 and s.p.punchin then
                        sc.region_length(i, punchin)
                        s.p.resetwindow(s)

                        s.p.punchin = nil
                    end

                    sc.play(i, v)
                end
            },
            slew_reset = metro.init(function() 
                sc.rate_slew(i, 0)
            end, 0, 1),
            rev = _grid.toggle:new {
                x = 1, y = i, lvl = { 4, 15 },
                action = function(s, v, t)
                    local st = (1 + (math.random() * 0.5)) * t
                    sc.rate_slew(i, st)
                    s.p.slew_reset:start(st)

                    sc.rate3(i, (v == 1) and 1 or -1)
                end
            },
            rate = _grid.glide:new {
                x = { 2, 11 }, y = i, v = 7
                action = function(s, v, t) 
                    local st = (1 + (math.random() * 0.5)) * t
                    sc.rate_slew(i, st)
                    s.p.slew_reset:start(st)

                    sc.rate(i, math.pow(2, v - 7))
                end,
                indicator = _grid.value.output:new { ---
                    x = 9, y = i, lvl = 4, order = -1
                }
            },
            pre_level = _control:new { 
                v = 0, mul = 1, action = function(s, v) sc.pre_level(i, v * s.mul) end
            },
            feedback = _control:new { 
                v = 0, mul = 0, action = function(s, v) sc.level_cut_cut(i, i, v * s.mul) end
            },
            route = _grid.toggle:new {
                x = { 4, 7 }, y = 3 + i,
                action = function(s, v) -- change v to matrix ?
                    for j,w in ipairs(v) do 
                        if j == i and w == 1 then
                            s.p.pre_level.mul = 0
                            s.p.pre_level:bang() ------

                            s.p.feedback.mul = 1
                            s.p.feedback:bang()
                        else 
                            sc.level_cut_cut(i, j, w) 

                            s.p.pre_level.mul = 1
                            s.p.pre_level:bang() ------

                            s.p.feedback.mul = 0
                            s.p.feedback:bang()
                        end
                    end
                end,
                indicator = _grid.value.output:new { ---
                    x = i + 3, y = i + 3, lvl = 4, order = -1
                }
            },
            local = {
                --mod position, friction
                --level, pan, mod, mod
                --start, length, mod, mod
                --fine pitch, mod, fade
                --filter pitch, crossfade, mod, resonance
            }
        }
    end),
    screen_global = {
        --feedback
        --dry/wet, samplerate, drive, width
    }
    pat = _grid.pattern:new {
        x = 16,
        y = { 1, 8 },
        lvl = { 4, 15 },
        target = function(s) s.p.tp end
    },
    arcpg = _grid.control:new {
        
    }
} :connect { 
    g = grid.connect(1), 
    arc = arc.connect(1),
    screen = screen, 
    enc = enc, 
    key = key
}

function init()
end

