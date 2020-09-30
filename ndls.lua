include 'lib/nest_.lua'

sc = include 'lib/supercut'

n = nest_:new {
    tp = nest_:new(1, 4):each(function(i)
        return {
            start = _arc.cycle:new {
                n = i,
                action = function(s, v)
                    sc.loop_start(i, v * sc.region_length(i)) -- v is 0-1
                end,
                enabled = function() return n.arcpg()[i][1] end
            },
            length = _arc.value:new {
                n = i,
                action = function(s, v)
                    sc.loop_length(i, v * sc.region_length(i))
                end,
                enabled = function() return n.arcpg()[i][2] end,
                output = { enabled = false } --
            },
            buffer = _grid.value:new {
                x = { 8, 15 }, y = i + 4, v = i
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
                x = 1, y = i + 4,
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
                x = 2, y = i + 4, lvl = { 4, 15 },
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
                x = { 4, 7 }, y = 4 + i,
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
                end
            }
            -------------------------
        }
    end),
    pat = _grid.pattern:new {
        x = 16,
        y = { 1, 8 },
        lvl = { 4, 15 },
        init = function(self) --
            self.target = n
        end
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
