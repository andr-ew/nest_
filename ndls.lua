include 'lib/nest_.lua'

sc = include 'lib/supercut'

n = nest_:new {
    tp = nest_:new(1, 4):each(function(i)
        return {
            start = _arc.cycle:new {
                n = i,
                action = function(s, v)
                    sc.loop_start(i, v / 64 * sc.region_length(i))
                end,
                enabled = function() return n.arcpg()[i][1] end
            },
            length = _arc.value:new {
                n = i,
                action = function(s, v)
                    sc.loop_length(i, v / 64 * sc.region_length(i))
                end,
                enabled = function() return n.arcpg()[i][2] end,
                output = { enabled = false } --
            },
            buffer = _grid.value:new {
                x = { 8, 15 }, y = i + 4,
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
                x = 2, y = i + 4,
                action = function(s, v)
                    if v == 1 and s.p.punchin then
                        sc.region_length(i, punchin)
                        s.p.resetwindow(s)

                        s.p.punchin = nil
                    end

                    sc.play(i, v)
                end
            }
        }
    end),
    pat = _grid.pattern:new {
        x = 15,
        y = { 1, 8 },
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
