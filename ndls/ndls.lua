include "nest_norns"

ndls_ = nest_:new {
    regsize = 100,
    voices = { 0, 1, 2, 3},
    region = {},
    loopsize = { self.regsize, self.regsize, self.regsize, self.regsize },
    channel = {},
    gridport = 0
}

ndls_:roost()

local n_ = ndls_
local _grid = _grids[n_.gridport]

n_.init = function() {
    for i, v in ipairs(n_.voices) do
        softcut.enable(v,1)
        softcut.loop(v,1)
        softcut.phase_quant(v, 1/16/4)
    end

    softcut.event_phase(
        function(voice, phase)
            for i,v in ipairs(n_.channels) do
                if v.voice == voice then
                    v.phase:set(phase * 16)
                end
            end
        end
    )
    softcut.poll_start_phase()
}

xpage = function(x) return function() return n_.page:get()[0] == x end end

for i = 1, 4 do
    ypage = function()
        local myi = i
        return function() return n_.page:get()[1] == myi end
    end
    n_.region[i] = { buff = voices[i] % 2,  s = (voices[i] - (voices[i] % 2)) * n_.regsize,  e = ((voices[i] - (voices[i] % 2)) + 1) * n_.regsize }

    n_.channel[i] = {
        newloop = true,
        punchin = 0,
        voice = n_.voices[i],
        region = n_.region[i],
        stutter = _grid.toggle:new{
            x = 0,
            y = i,
            edge = 0,
            e = function(s, v, meta)
                if v then
                    endd = s.p.phase:get()
                    softcut.loop_end(s.p.voice, math.min(endd, s.p.region.e))
                    softcut.loop_start(s.p.voice, math.max(endd - meta.time, s.p.region.s))
                else
                    softcut.loop_start(s.p.voice, s.p.region.s)
                    softcut.loop_end(s.p.voice, s.p.region.s + s.p.region.loopsize)
                end
            end
        },
        rate = _grid.value:new{ -- _grid.glide
            x = {1, 15},
            y = i,
            v = 7,
            e = function(s, v, meta)
                r = 0
                if v < 7 then
                    r = math.pow(2, (6 - v) - 5)
                elseif v > 7 then
                    r = math.pow(2, v - 12)
                end

                if self.edge then
                    softcut.rate_slew_time(s.p.voice, 0)
                else
                    softcut.rate_slew_time(s.p.voice, meta.time * (1.3 + (math.random() * 0.5)))
                end

                softcut.rate(s.p.voice, r * s.p.bend:get())
            end
        },
        phase = _grid.value:new{
            x = {0, 15},
            y = i,
            order = -1,
            inputut.enabled = false
        },
        record = _grid.toggle:new{
            x = 0,
            y = i + 4,
            offlvl = _low,
            e = function(s, v)
                if s.p.play:get() == 0 then
                    if v then
                        s.p.newloop = true
                        s.p.region.loopsize = n_.regsize
                        softcut.buffer_clear_region_channel(s.p.region.buff, s.p.region.s, s.p.region.e)
                        softcut.loop_start(s.p.voice, s.p.region.s)
                        softcut.loop_end(s.p.voice, s.p.region.s + s.p.region.loopsize)
                        softcut.play(s.p.voice, 1)
                        s.p.punchin = util.time()
                    else
                        s.p.newloop = false
                        s.p.region.loopsize = util.time() - s.p.punchin

                        softcut.loop_start(s.p.voice, s.p.region.s)
                        softcut.loop_end(s.p.voice, s.p.region.s + s.p.region.loopsize)
                        s.p.play:set(1)
                    end
                end

                softcut.rec(s.p.voice, v)
            end
        },
        play = _grid.toggle:new{
            x = 1,
            y = i + 4,
            e = function(s, v)
                if s.p.newloop then
                    if v then
                        s.p.newloop = false
                        s.p.region.loopsize = util.time() - s.p.punchin

                        softcut.loop_start(s.p.voice, s.p.region.s)
                        softcut.loop_end(s.p.voice, s.p.region.s + s.p.region.loopsize)
                        s.p.play:set(1)
                    end
                end

                softcut.play(s.p.voice, v)
            end
        },
        glide = _grid.momentary:new{
            x = 2,
            y = i + 4,
            offlvl = _low,
            e = function(s, v) s.p.rate.edge = v == 0 end
        },
        buffer = _grid.value:new{
            x = {3, 6},
            y = i + 4,
            v = i,
            e = function(s, v)
                s.p.region = n_.region[v]
                s.p.region.loopsize = n_.region.loopsize[v]

                softcut.loop_start(s.p.voice, s.p.region.s)
                softcut.loop_end(s.p.voice, s.p.region.s + s.p.region.loopsize)
            end
        },
        route = _grid.value:new{
            x = {7, 10},
            y = i + 4,
            v = i,
            e = function(s, v)
                softcut.level_cut_cut(s.p.voice, n_.voices[v], s.p.feedback:get() * n_.dub:get())
            end
        },
        feedback = _grid.toggle:new{
            x = 11,
            y = i + 4,
            v = i,
            e = function(s, v)
                softcut.level_cut_cut(s.p.voice, n_.voices[s.p.route:get()], v * n_.dub:get())
            end
        },
        pattern = _grid.pattern:new{
            x = 15,
            y = i + 4,
            target = _
        }
    }
end

n_.page = _grid.value:new{
    x = {14, 15},
    y = {4, 7}
}
