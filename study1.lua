-- nest_ study 1
-- nested affordances
--
--    1-5
-- 1: strum 1
-- 2: strum 2
-- 3: strum 3
-- 4: strum 4
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

engine.name = "PolyPerc"

scale = { 0, 2, 4, 7, 9 } -- scale degrees in semitones
root = 440 * 2^(5/12) -- the d above middle a

function play(deg, oct)
    local octave = oct - 3
    local note = scale[deg]
    local hz = root * 2^octave * 2^(note/12)
    
    engine.hz(hz)
end

strum = nest_ {
    _grid.number {
        x = { 1, 5 },
        y = 1,
        value = math.random(5),
        
        action = function(self, value)
            -- play a note
            play(value, self.y)
        end
    },
    _grid.number {
        x = { 1, 5 },
        y = 2,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            local above = strum[self.key - 1]
            
            clock.run(function()
                clock.sleep(0.2)
                
                above.value = (above.value == 1) and 5 or (above.value - 1) 
                above:update()
            end)
        end
    },
    _grid.number {
        x = { 1, 5 },
        y = 3,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            local above = strum[self.key - 1]
            
            clock.run(function()
                clock.sleep(0.15)
                
                above.value = math.random(5)
                above:update()
            end)
        end
    },
    _grid.number {
        x = { 1, 5 },
        y = 4,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            local above = strum[self.key - 1]
            
            clock.run(function()
                clock.sleep(0.1)
                
                above.value = above.value % 5 + 1,
                above:update()
            end)
        end
    }
}

strum:connect { g = grid.connect() }

function init() 
    strum:init()
end