-- nest_ study 2
-- the grid & multiples
--
-- grid:
--   1 : page select
-- 2-6: note/octave
--   3: gate
--   4: step

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

engine.name = "PolyPerc"

scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

seq = nest_ {
    tab = _grid.number {
        x = { 1, 2 },
        y = 1,
        level = { 4, 15 },
    },
    pages = nest_ {
        nest_ {
            notes = nest_(16):each(function(i)
                return _grid.number {
                    x = i,
                    y = { 2, 6 },
                    value = math.random(1, 5), -- initialize every note with a random number
                    
                    -- adjust the brightness level based on step & gates
                    level = function(self)
                        if seq.gates.value[i] == 0 then return 0 -- if this step's gate is off set brightness low
                        elseif seq.step.value == i then return 15 -- if it's the current step set level high 
                        else return 4 end -- otherwise set dim
                    end,
                }
            end),
            enabled = function(self)
                return (seq.tab.value == self.key)
            end
        },
        nest_ {
            octaves = nest_(16):each(function(i)
                return _grid.number {
                    x = i,
                    y = { 2, 6 },
                    value = 3,
                    level = function(self)
                        if seq.gates.value[i] == 0 then return 0
                        elseif seq.step.value == i then return 15
                        else return 4 end
                    end
                }
            end),
            enabled = function(self)
                return (seq.tab.value == self.key)
            end
        }
    }:each(function(i, v)
        v.enabled = function(self)
            return (seq.tab.value == self.key)
        end
    end),
    gates = _grid.toggle {
        x = { 1, 16 },
        y = 7,
        level = 4,
        value = 1 -- a shortcut, toggle knows to set all the toggle values to 1
    },
    step = _grid.number {
        x = { 1, 16 },
        y = 8
    }
}

-- sequencer counter
count = function()
    while true do -- loop forever
        
        local step = seq.step.value -- the current step
        
        if seq.gates.value[step] == 1 then -- if the current gate is high
            
            -- find note frequency
            local note = scale[seq.pages[1].notes[step].value]
            local octave = seq.pages[2].octaves[step].value - 4
            local hz = root * 2^octave * 2^(note/12)
            
            engine.hz(hz) -- send a note to the engine
        end
        
        seq.step.value = step % 16 + 1 -- incriment & wrap step
        seq.step:update()
        
        clock.sync(1/4) -- wait for the next quarter note
    end
end

-- connect the nest to a grid device
seq:connect {
    g = grid.connect()
}

-- initialize the nest, start counting
function init()
    seq:init()
    clock.run(count)
end