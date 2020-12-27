function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/arc'

tab = require 'tabutil'

n = nest_ {
    gl = _arc.option {
        n = 4,
        sens = 1/16,
        options = 2,
        glyph = function(s, v, c)
            local r = {}
            for i = 1, c do
                r[i] = v == 1 and math.floor(i * 15 / c) or 15 - math.ceil(i * 15 / c)
            end
            return r
        end,
        action = function(s, v) print(v) end
    },
    f = _arc.option {
        x = { 42, 24 },
        n = 3,
        sens = 1/16,
        --size = { 1, 2, 4, 8 },
        include = { 1, 2, 4 },
        size = 4,
        margin = 0,
        lvl = { 0, 4, 15 },
        action = function(s, v) print(v) end
    },
    b = _arc.key.trigger {
        n = 3,
        action = function(s, v) print(v) end
    }
} :connect({ a = arc.connect() }, 120)



--[[
    f = _arc.option {
        x = { 42, 24 },
        n = 4,
        sens = 1/16,
        size = { 1, 2, 4, 8 },
        margin = 0,
        lvl = { 0, 4, 15 },
        action = function(s, v) print(v) end
    }

    gl = _arc.option {
        n = 4,
        sens = 1/16,
        options = 2,
        glyph = function(s, v, c)
            local r = {}
            for i = 1, c do
                r[i] = v == 1 and math.floor(i * 15 / c) or 15 - math.ceil(i * 15 / c)
            end
            return r
        end,
        action = function(s, v) print(v) end
    },
    f = _arc.option {
        x = { 42, 24 },
        n = 3,
        sens = 1/16,
        --size = { 1, 2, 4, 8 },
        size = 4,
        margin = 0,
        lvl = { 0, 4, 15 },
        action = function(s, v) print(v) end
    }
    gl = _arc.option {
        n = 4,
        sens = 1/16,
        options = 2,
        glyph = function(s, v, c)
            local r = {}
            for i = 1, c do
                r[i] = v == 1 and math.floor(i * 15 / c) or 15 - math.ceil(i * 15 / c)
            end
            return r
        end,
        action = function(s, v) print(v) end
    },
    f = _arc.option {
        x = { 42, 24 },
        n = 3,
        sens = 1/16,
        --size = { 1, 2, 4, 8 },
        include = { 1, 2, 4 },
        size = 4,
        margin = 0,
        lvl = { 0, 4, 15 },
        action = function(s, v) print(v) end
    },
    b = _arc.key.trigger {
        n = 3,
        action = function(s, v) print(v) end
    }
--]]
