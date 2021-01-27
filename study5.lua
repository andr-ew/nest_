-- nest_ study 5
-- making a script

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'

--[[

grid (polysub):

     1-8               9-16
  1: pattern recorder  preset selector
2-8: scale octaves     controls   


screen (delay):

e1: delay
e2: rate
e3: feedback
k2: reverse

--]]

polysub = include 'we/lib/polysub'
delay = include 'awake/lib/halfsecond'
local cs = require 'controlspec'

scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

engine.name = 'PolySub'

synth = nest_ {
    grid = nest_ {
        
        -- keyboard & meta-affordances
        pattern_group = nest_ {
            keyboard = _grid.momentary {
                
                x = { 1, #scale }, -- notes on the x axis
                y = { 2, 8 },-- octaves on the y axis
                
                action = function(self, value, t, d, added, removed)
                    
                    local key = added or removed -- the key that was pressed or released
                    
                    local id = key.y * 7 + key.x -- a unique integer for this grid key
                    
                    local octave = key.y - 4
                    local note = scale[key.x]
                    local hz = root * 2^octave * 2^(note/12)
                    
                    if added then engine.start(id, hz)
                    elseif removed then engine.stop(id) end
                end
            },
            control_preset = _grid.preset { -- preset selector for the faders
                y = 1, x = { 9, 16 },
                target = function(self) return synth.grid.controls end
            }
        },
        pattern = _grid.pattern { -- pattern recorder for the keyboard + preset selector
            y = 1, x = { 1, 8 },
            target = function(self) return synth.grid.pattern_group end
        },
    
        -- synth controls
        controls = nest_ {
            shape = _grid.control {
                x = 9, y = { 2, 8 },
                action = function(self, value) engine.shape(value) end
            },
            timbre = _grid.control {
                x = 10, y = { 2, 8 },
                v = 0.5,
                action = function(self, value) engine.timbre(value) end
            },
            noise = _grid.control {
                x = 11, y = { 2, 8 },
                action = function(self, value) engine.noise(value) end
            },
            hzlag = _grid.control {
                x = 12, y = { 2, 8 },
                action = function(self, value) engine.hzLag(value) end
            },
            cut = _grid.control {
                x = 13, y = { 2, 8 },
                range = { 0, 32 },
                value = 16,
                action = function(self, value) engine.cut(value) end
            },
            attack = _grid.control {
                x = 14, y = { 2, 8 },
                range = { 0.01, 10 },
                value = 0.01,
                action = function(self, value)
                    engine.cutAtk(value)
                    engine.ampAtk(value)
                end
            },
            sustain = _grid.control {
                x = 15, y = { 2, 8 },
                value = 1,
                action = function(self, value)
                    engine.cutSus(value)
                    engine.ampSus(value)
                end
            },
            release = _grid.control {
                x = 16, y = { 2, 8 },
                range = { 0.01, 10 },
                value = 0.01,
                action = function(self, value)
                    engine.cutDec(value)
                    engine.ampDec(value)
                    engine.cutRel(value)
                    engine.ampRel(value)
                end
            }
        }
    },
    
    -- delay controls
    screen = nest_ {
        delay = _txt.enc.control {
            x = 2, y = 18,
            value = 0.5,
            n = 1,
            action = function(self, value) softcut.level(1, value) end
        },
        rate = _txt.enc.control {
            x = 2, y = 38,
            range = { 0.5, 2 },
            value = 0.5,
            n = 2,
            action = function(self, value) 
                local dir = (self.parent.reverse.value > 0) and -1 or 1
                softcut.rate(1, value * dir) 
            end
        },
        feedback = _txt.enc.control {
            x = 64, y = 38,
            n = 3,
            value = 0.75,
            action = function(self, value) softcut.rate(1, value) end
        },
        reverse = _txt.key.toggle {
            x = 2, y = 50,
            n = 2,
            action = function(self) self.parent.rate:update() end
        }
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
    delay.init()
    polysub.params()
    
    --synth:load()
    synth:init()
end

function cleanup()
    --synth:save()
end