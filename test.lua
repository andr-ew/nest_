function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
tab = require 'tabutil'

o = _obj_:new {
    t = _obj_:new {
        'one',
        'two',
        'three',
        { 1, 2, 4 },
        a = 3,
        b = "foo",
    }
}
