function r()
  norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_'
tab = require 'tabutil'

--i = _input:new { b = 2 }
c = _control:new { inputs = { _input:new { b = 2 } }, test = 1 }
--i.control = c -- set manually
--rawset(i, 'control', c) -- that should be better, eek
--i.test -- > 1
--i.foo -- > stack overflow
--c.foo -- > stack overflow - the real culprit !
--c.p.is_nest -- > stack overflow - getting weirder

--print(i.a) -- not stack overflow
--c.inputs[1] = i -- stack overflow

--c = _control:new{ inputs = { i } } -- stack overflow

-- c.p == i, lol. that is very much a problem

--[[
c = _control:new {
    v = 1,
    inputs = {
        _input:new { foo = "bar" }
    }
}
cc = c:new { v = 2 }
cc.input.foo = 'bingo'
]]

--_grid = include 'lib/nest_grid'

--[[
n = nest_:new {
    --welp, this is very wrong, new inheritance model maybe will fix hehe
    v = _grid.value:new {
        x = { 1, 2 },
        y = 1,
        v = 0
    },
    m = _grid.momentary:new {
        x = { 3, 4 },
        y = 1,
        v = {}
    }
} :connect { g = grid.connect() } 
]]
