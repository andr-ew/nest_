-- grid advanced properties

include '../lib/nest_/core'
include '../lib/nest_/norns'
include '../lib/nest_/grid'

---------------------------------------------------------------------

local grid_trigger_level = { 
    4,
    function(s, draw)
        draw(15)
        clock.sleep(0.1)
        draw(4)
    end
}

local function gridaction(self, value)
    print(self.key, self.value)
end

---------------------------------------------------------------------

advanced = nest_ {
    
    -- more than two states may be supplied to toggle to cycle forward through values
    -- this toggle has four states - two solid brightness values and two blinking patterns
    modal_toggle = _grid.toggle {
        x = 1, 
        y = 3,
        lvl = { 
            -- a state may be a static brightness level or a clock function, drawing sequential brighness levels with a callback 
            4, 
            15,
            function(self, draw)
                while true do
                    draw(15)
                    clock.sleep(0.2)
                    draw(4)
                    clock.sleep(0.2)
                end
            end,
            function(self, draw)
                while true do
                    draw(15)
                    clock.sleep(0.1)
                    draw(0)
                    clock.sleep(0.1)
                    draw(15)
                    clock.sleep(0.1)
                    draw(0)
                    clock.sleep(0.6)
                end
            end
        },
        action = gridaction
    },

    -- a trigger that fades in & out via clock function
    fancy_trigger = _grid.trigger {
        x = 3,
        y = 3,
        lvl = {
            1,
            function(self, draw)
                for i = 1, 15 do
                    draw(i)
                    clock.sleep(0.03)
                end
                for i = 15, 1, -1 do
                    draw(i)
                    clock.sleep(0.03)
                end
            end
        },
        action = gridaction
    },

    -- the fingers arguments limits input to a range of concurrently held keys. two_trigger only fires when two keys are pressed at once.
    two_trigger = _grid.trigger {
        x = { 1, 4 },
        y = 5,
        lvl = grid_trigger_level,
        fingers = { 2, 2 },
        action = gridaction
    },

    -- edge specifies whether to fire on a rising edge (1, default) or falling edge (0). 
    -- detecting value on a falling edge triggers reveals key combos in value
    combo_trigger = _grid.trigger {
        x = { 6, 9 },
        y = 5,
        lvl = grid_trigger_level,
        edge = 0,
        action = gridaction
    },

    -- count limits concurrent high values. no more than two keys may be lit in limit_toggle.
    limit_toggle = _grid.toggle {
        x = { 1, 7 },
        y = 7,
        lvl = { 4, 15 },
        count = 2,
        action = gridaction
    },
} :connect { g = grid.connect() }

function init() advanced:init() end