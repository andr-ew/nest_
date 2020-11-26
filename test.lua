function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/txt'

tab = require 'tabutil'

n = nest_ {
    _txt.label {
        value = 'e',
        border = 15,
        font = 1,
        --size = 16,
        padding = 2
    }
} :connect { key = key, enc = enc, screen = screen }

