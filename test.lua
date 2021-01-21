function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

tab = require 'tabutil'

---[[
g = nest_ {
    n = _grid.number {
        x = { 1, 8 }, y = function() return 1 end,
        action = function(s, v)
            print(v)
        end
    }
} :connect { g = grid.connect() }

g:insert {
    foo = 'var',
    n = {
        y = 1,
        foo2 = 'bar2'
    }
}

ob = _obj_:new()
ob.test = 'test'

function init() 
    g:load()
    g:init() 
end

function cleanup()
    g:save()
end
--]]

--[[
n = nest_ {
    a = _affordance {
        input = _input()
    }
}
--]]
