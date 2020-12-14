function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/txt'

tab = require 'tabutil'

n = nest_ {
    l = _txt.enc.list {
        y = 4,
        x = { 4, 64 },
        n = 2,
        items = nest_ { 
            _txt.enc.control { n = 3, label = "foo" },
            _txt.key.toggle { n = 3, label = "bar" },
            _txt.enc.control { n = 3, label = "ding" },
            _txt.enc.option { n = 3, label = "bat", options = { "a", "bbb", "c" } },
            _txt.enc.control { n = 3, label = "foo" },
            _txt.key.momentary { n = { 2, 3 }, label = "bar" },
            _txt.enc.control { n = 3, label = "ding" },
            _txt.enc.control { n = 3, label = "bat" }
        },
        flow = 'y',
        scroll_window = 5,
        scroll_focus = 3,
    }
} :connect { key = key, enc = enc, screen = screen }  
