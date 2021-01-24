function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/arc'

tab = require 'tabutil'

g = nest_ {
    _grid.control {
        x = { 2, 7 },
        y = 2,
        action = function(s, v) print(v) end
    },
    _grid.control {
        x = 1, y = { 2, 7 },
        action = function(s, v) print(v) end
    }
} :connect { g = grid.connect() }

function init() 
    g:init() 
end

function cleanup()
end
