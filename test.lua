function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/arc'

tab = require 'tabutil'

---[[
g = nest_ {
    number1 = _arc.number {
        n = 2,
        sens = 1/2,
        action = function(self, value) print(self.k, value) end
    },
    tab = _arc.option {
        x = { 42, 24 }, n = 1,
        sens = 1/16,
        options = 4,
        size = 3,
        lvl = { 0, 4, 15 },
        action = function(self, value) print(self.k, value) end
    }
} :connect { a = arc.connect() }

function init() 
    g:init() 
end

function cleanup()
end
--]]

--[[
n = nest_ {
    a = _affordance {
        input = _input()
    }
}
--]]
