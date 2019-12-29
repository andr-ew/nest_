include "nest_000000"

local s_ = screen_:new()
local e_ = engine:new("pss13")


local g_ = grid_:new{
    bank = {
        grid_value:new{
            x = {0, 3},
            y = 0
        },
        grid_value:new{
            x = {0, 3},
            y = 1
        },
        grid_value:new{
            x = {0, 3},
            y = 2
        },
        grid_value:new{
            x = {4, 7},
            y = 0
        },
        grid_value:new{
            x = {4, 7},
            y = 1
        },
        grid_toggle:new{
            x = 4,
            y = 2
        },
        grid_toggle:new{
            x = 5,
            y = 2
        }
    },
    gridkeyboard = grid_keyboard_et:new{ ---?????
        x = {0, 7},
        y = {3, 7},
        root = 440,
        scale = {"D", "E", "G", "A", "B"},
        rowintervals = {1,1,1,1,1},
        transposition = 3,
        link = e_.notes
    }
}

bank[0].v = 1
bank[0].link = {
    e_.osc1_oct,
    e_.osc2_oct,
    e_.osc3_oct,
}
bank[1].link = e_.osc2_oct

s_ = screen_:new{
    sections = { -------?
        x = { MAX, MAX },
        y = { MAX, MAX, MAX }
    },
    degrade = screen_value:new{
        yalign = CENTER,
        x = 1,
        y = 1,
        encoder = _enc_value:new{
            n = 1,
            range = { 0, 1 }
        },
        label = "degrade",
        link = {
            
        }
    },
    level1 = screen_value:new{
        yalign = CENTER,
        x = 1,
        y = 2,
        encoder = _enc_value:new{
            n = 2,
            range = { 0, 1 }
        },
        label = "level",
        link = {
            
        }
    },
    brightness = screen_value:new{
        yalign = CENTER,
        x = 2,
        y = 2,
        encoder = _enc_value:new{
            n = 3,
            range = { 0, 1 }
        },
        label = "brightness",
        link = {
            
        }
    }
}