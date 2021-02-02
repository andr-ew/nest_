-- nest_ study 1
-- nested affordances
--
--    1-5
-- 1: strum a
-- 2: strum b
-- 3: strum c
-- 4: strum d
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
    a = _grid.number {
        x = { 1, 5 },
        y = 1,
        value = math.random(5),
        
        action = function(self, value)
            -- play a note
            play(value, self.y)
        end
    },
    b = _grid.number {
        x = { 1, 5 },
        y = 2,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            
            -- decriment & wrap a
            clock.run(function()
                clock.sleep(0.2)
                
                strum.a.value = (strum.a.value == 1) and 5 or (strum.a.value - 1) 
                strum.a:update()
            end)
        end
    },
    c = _grid.number {
        x = { 1, 5 },
        y = 3,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            
            -- randomize b
            clock.run(function()
                clock.sleep(0.15)
                
                strum.b.value = math.random(5)
                strum.b:update()
            end)
        end
    },
    d = _grid.number {
        x = { 1, 5 },
        y = 4,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            
            -- incriment & wrap c
            clock.run(function()
                clock.sleep(0.1)
                
                strum.c.value = strum.c.value % 5 + 1,
                strum.c:update()
            end)
        end
    }
}

strum:connect { g = grid.connect() }

function init() 
    strum:init()
end