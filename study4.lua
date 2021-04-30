-- nest_ study 4
-- state & meta-affordances
--
-- grid (synth):
--      1-8        9-16
--   1:  patterns  presets
-- 2-8: keybaord  controls   
--
-- screen (delay):
-- e1: delay
-- e2: rate
-- e3: feedback
-- k2: reverse

include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'
include 'lib/nest/txt'

polysub = include 'we/lib/polysub'
delay = include 'awake/lib/halfsecond'
local cs = require 'controlspec'

scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

engine.name = 'PolySub'

polysub.params()
delay.init()
    
synth = nest_ {
    grid = nest_ {
        pattern_group = nest_ {
            keyboard = _grid.momentary {
                x = { 1, #scale }, -- notes on the x axis
                y = { 2, 8 },-- octaves on the y axis
                
                action = function(self, value, t, d, added, removed)
                    local key = added or removed
                    local id = key.y * 7 + key.x -- a unique integer for this grid key
                    
                    local octave = key.y - 5
                    local note = scale[key.x]
                    local hz = root * 2^octave * 2^(note/12)
                    
                    if added then engine.start(id, hz)
                    elseif removed then engine.stop(id) end
                end
            },
            control_preset = _grid.preset {
                y = 1, x = { 9, 16 },
                target = function(self) return synth.grid.controls end
            }
        },
        pattern = _grid.pattern {
            y = 1, x = { 1, 8 },
            target = function(self) return synth.grid.pattern_group end,
            stop = function()
                synth.grid.pattern_group.keyboard:clear()
                engine.stopAll()
            end
        },
    
        -- synth controls
        controls = nest_ {
            shape = _grid.control {
                x = 9, y = { 2, 8 },
            } :link('shape'),
            timbre = _grid.control {
                x = 10, y = { 2, 8 },
            } :link('timbre'),
            noise = _grid.control {
                x = 11, y = { 2, 8 },
            } :link('sub'),
            hzlag = _grid.control {
                x = 12, y = { 2, 8 },
            } :link('noise'),
            cut = _grid.control {
                x = 13, y = { 2, 8 },
            } :link('cut'),
            attack = _grid.control {
                x = 14, y = { 2, 8 },
            } :link('ampatk'),
            sustain = _grid.control {
                x = 15, y = { 2, 8 },
            } :link('ampsus'),
            release = _grid.control {
                x = 16, y = { 2, 8 },
            } :link('amprel')
        }
    },
    
    -- delay controls
    screen = nest_ {
        delay = _txt.enc.control {
            x = 2, y = 16, 
            n = 1,
        } :link('delay'),
        rate = _txt.enc.control {
            x = 2, y = 44, 
            n = 2
        } :link('delay_rate'),
        feedback = _txt.enc.control {
            x = 64, y = 44,
            n = 3,
        } :link('delay_feedback'),
    }
}

synth.grid:connect {
    g = grid.connect()
}

synth.screen:connect {
    screen = screen,
    key = key,
    enc = enc
}

function init()
    synth:load()
    params:read()
    synth:init()
    params:bang()
end

function cleanup()
    synth:save()
    params:write()
end
