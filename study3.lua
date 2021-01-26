-- nest_ study 3
-- affordance demo

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'
include 'lib/nest_/arc'

-------------------------------------------------utility functions

local function gpage(self) return demo.grid.tab.value == self.k end
local function tpage(self) return demo.txt.tab.options[demo.txt.tab.value // 1] == self.k end
local function apage(self) return demo.arc.tab.value // 1 == self.k end

local grid_trigger_level = { 
    4,
    function(s, draw)
        draw(15)
        clock.sleep(0.1)
        draw(4)
    end
}

local function gridaction(self, value, time, delta, add, rem, list)
    print(self.key)
    print('args:')
    print('1. self')
    print('2. value: ' .. tostring(value))
    print('3. time: ' .. tostring(time))
    print('4. delta: ' .. tostring(delta))
    print('5. add: ' .. tostring(add))
    print('6. remove: ' .. tostring(rem))
    print('7. list: ' .. tostring(list))
end

demo = nest_()

-------------------------------------------------grid

demo.grid = nest_ {
    page = nest_ {
        -----------------------------------------fill
        nest_ { 
            fill_0d = _grid.fill {
                x = 1,
                y = 3,
                lvl = 15
            }, 
            fill_1d = _grid.fill {
                x = { 1, 7 },
                y = 5,
                lvl = 15
            },
            fill_2d = _grid.fill {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = 15
            },
            enabled = gpage
        },
        -----------------------------------------number
        nest_ {
            number_0d = _grid.number {
                x = 1,
                y = 3,
                lvl = { 4, 15 },
                action = gridaction
            }, 
            number_1d = _grid.number {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action =  gridaction
            }, 
            number_2d = _grid.number {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = gridaction
            },
            enabled = gpage
        },
        -----------------------------------------control
        nest_ {
            control_0d = _grid.control {
                x = 1,
                y = 3,
                action = gridaction
            }, 
            control_1d = _grid.control {
                x = { 1, 7 },
                y = 5,
                range = { 0, 1 },
                action = gridaction
            }, 
            control_2d = _grid.control {
                x = { 9, 15 },
                y = { 2, 8 },
                range = { 0, 1 },
                action = gridaction
            },
            enabled = gpage
        },
        -----------------------------------------trigger
        nest_ {
            trigger_0d = _grid.trigger {
                x = 1,
                y = 3,
                lvl = grid_trigger_level,
                action = gridaction
            }, 
            trigger_1d = _grid.trigger {
                x = { 1, 7 },
                y = 5,
                lvl = grid_trigger_level,
                action = gridaction
            }, 
            trigger_2d = _grid.trigger {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = grid_trigger_level,
                action = gridaction
            },
            enabled = gpage
        },
        -----------------------------------------toggle
        nest_ {
            toggle_0d = _grid.toggle {
                x = 1,
                y = 3,
                lvl = { 4, 15 },
                action = gridaction
            }, 
            toggle_1d = _grid.toggle {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action = gridaction
            }, 
            toggle_2d = _grid.toggle {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = gridaction
            },
            enabled = gpage
        },
        -----------------------------------------momentary
        nest_ {
            momentary_0d = _grid.momentary {
                x = 1,
                y = 3,
                lvl = { 4, 15 },
                action = gridaction
            }, 
            momentary_1d = _grid.momentary {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action = gridaction
            }, 
            momentary_2d = _grid.momentary {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = gridaction
            },
            enabled = gpage
        },
        -----------------------------------------range
        nest_ {
            range_0d = _grid.range {
                x = 1,
                y = 3,
                action = gridaction
            }, 
            range_1d = _grid.range {
                x = { 1, 7 },
                y = 5,
                action = gridaction
            }, 
            range_2d = _grid.range {
                x = { 9, 15 },
                y = { 2, 8 },
                action = gridaction
            },
            enabled = gpage
        },
    },
    tab = _grid.number {
        x = { 1, 7 },
        y = 1,
        lvl = { 4, 15 }
    }
} :connect {
    g = grid.connect()
}

-------------------------------------------------txt/screen

demo.txt = nest_ {
    page = nest_ {
        -------------------------------------numerical
        numerical = nest_ {
            trigger = _txt.key.trigger {
                x = 2, y = 18,
                n = 1,
                action = function(self, value) print(self.k, value) end,
            },
            number = _txt.enc.number {
                x = 2, y = 38,
                n = 2,
                range = { 1, 8 },
                wrap = true,
                align = { 'left', 'bottom' },
                action = function(self, value) print(self.k, value) end,
                label ="foo"
            },
            control = _txt.enc.control {
                x = 64, y = 38,
                n = 3,
                controlspec = controlspec.BIPOLAR,
                align = { 'left', 'bottom' },
                action = function(self, value) print(self.k, value) end
            },
            momentary = _txt.key.momentary {
                x = 2, y = 50, 
                n = 2,
                action = function(self, value) print(self.k, value) end
            },
            toggle = _txt.key.toggle {
                x = 64, y = 46, 
                n = 3,
                padding = 4,
                lvl = { 15, 0 },
                fill = { 0, 15 },
                border = 15,
                edge = 0,
                action = function(self, value) print(self.k, value) end
            },
            enabled = tpage
        },
        -------------------------------------label / display properies
        label = nest_ {
            label1 = _txt.label {
                x = 2, y = 14,
                value = "hello, nest_"
            },
            label2 = _txt.label {
                x = 2, y = 24, 
                margin = 6,
                padding = 2,
                lvl = 0,
                fill = 15,
                value = { "one", "two", "three" }
            },
            label3 = _txt.label {
                x = { 46, 128 - 2 }, y = 44,
                lvl = { 15, 7, 2 },
                value = { "four", "five", "six" }
            },
            label4 = _txt.label {
                x = 128 - 2, y = 64 - 4,
                margin = 8,
                align = { 'right', 'bottom' },
                lvl = { 2, 7, 15 },
                value = { "seven", "eight", "nine" }
            },
            label5 = _txt.label {
                x = 128 - 2, y = 14,
                flow = 'y',
                align = 'right',
                --lvl = 7,
                value = { "ten", "eleven", "twelve" }
            },
            label6 = _txt.label {
                x = { 2, 44 - 4 },
                y = { 38, 64 - 2 },
                border = 15,
                value = "button"
            },
            enabled = tpage
        },
        -------------------------------------option (also see tab)
        option = nest_ {
            option1 = _txt.key.option {
                x = 2, y = 24,
                n = { 2, 3 },
                line_wrap = 3,
                options = { 'one', 'two', 'three', 'four', 'five' },
                action = function(self, value, option) print(self.k, option) end
            },
            option2 = _txt.enc.option {
                x = 82,
                y = 24,
                n = { 3, 2 },
                flow = 'y',
                size = 10,
                margin = 0, 
                padding = 3,
                border = { 0, 15 },
                options = { 
                    { 'a', 'b', 'c', 'd' },
                    { 'e', 'f', 'g', 'h' },
                    { 'i', 'j', 'k', 'l' },
                    { 'm', 'n', 'o', 'p' }
                },
                action = function(self, value, option) print(self.k, option) end
            },
            enabled = tpage
        },
        -------------------------------------list
        list = nest_ {
            list1 = _txt.enc.list {
                y = 14,
                x = { 2, 96 },
                n = 2,
                sens = 0.5,
                items = nest_ { 
                    _txt.enc.control { n = 3, label = "control 1" },
                    _txt.key.toggle { n = 3, label = "toggle" },
                    _txt.enc.control { n = 3, label = "control 2" },
                    _txt.enc.option { n = 3, label = "option", options = { "a", "b", "c", "d" } },
                    _txt.enc.control { n = 3, label = "control 3" },
                    _txt.key.momentary { n = { 2, 3 }, label = "momentary" },
                    _txt.enc.control { n = 3, label = "control 4" },
                    _txt.enc.control { n = 3, label = "control 5" }
                },
                flow = 'y',
                scroll_window = 5,
                scroll_focus = 3,
            },
            enabled = tpage
        }
    },
    tab = _txt.enc.option {
        x = 2, y = 2, n = 1, margin = 6,
        sens = 0.5,
        options = {
            "numerical",
            "label",
            "option",
            "list"
        }
    }
} :connect {
    key = key,
    enc = enc,
    screen = screen
}

---------------------------------------------TODO: nest_.redraw: animated screen drawing example
--[[ _screen {
    redraw = function(self, v)
        screen.drawthing(v)
    end,
    init_action = function(self)
        clock.run(function()
            while true do
                for i = 1, 3 do
                    self.value = 3
                    self:refresh()
                    clock.sleep(0.2)
                end
            end
        end)
    end
}
]]

---------------------------------------------arc

demo.arc = nest_ {
    page = nest_ {
        -------------------------------------fill & delta
        nest_ {
            fill1 = _arc.fill {
                n = 2,
                v = 1/64,
                lvl = 15
            },
            fill2 = _arc.fill {
                n = 3,
                v = { 0.2, 0.5 },
                lvl = 7
            },
            fill3 = _arc.fill {
                n = 4,
                v = { 0, 4, 7, 15, 0, 4, 7, 15 }
            },
            delta = _arc.delta {
                n = 2,
                action = function(self, d) print(self.k, d) end
            },
            enabled = apage
        },
        -------------------------------------number
        nest_ {
            number1 = _arc.number {
                n = 2,
                sens = 1/2,
                action = function(self, value) print(self.k, value) end
            },
            number2 = _arc.number {
                n = 3,
                sens = 1/6,
                value = 0.2,
                range = { 0.2, 0.4 },
                wrap = true,
                action = function(self, value) print(self.k, value) end
            },
            number3 = _arc.number {
                n = 4,
                sens = 2,
                range = { -math.huge, math.huge },
                cycle = 20,
                action = function(self, value) print(self.k, value) end
            },
            enabled = apage
        },
        -------------------------------------control
        nest_ {
            control1 = _arc.control {
                n = 2,
                sens = 1/2,
                action = function(self, value) print(self.k, value) end
            },
            control2 = _arc.control {
                n = 3,
                sens = 1/4,
                range = { -1, 1 },
                action = function(self, value) print(self.k, value) end
            },
            control3 = _arc.control {
                n = 4,
                x = { 40, 40 + 12 },
                sens = 1,
                lvl = { 4, 4, 15 },
                action = function(self, value) print(self.k, value) end
            },
            enabled = apage
        },
        -------------------------------------option
        nest_ {
            option1 = _arc.option {
                x = { 42, 24 },
                n = 2,
                sens = 1/16,
                range = { 1, 4 },
                size = { 1, 2, 4, 8, 16 },
                margin = 1,
                lvl = { 0, 4, 15 },
                action = function(s, v) print(math.floor(v)) end
            },
            option2 = _arc.option {
                --x = { 42, 24 },
                n = 3,
                sens = 1/16,
                include = { 1, 2, 4 },
                size = 4,
                margin = 0,
                lvl = { 0, 4, 15 },
                action = function(s, v) print(math.floor(v)) end
            },
            option3 = _arc.option {
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
                action = function(s, v) print(math.floor(v)) end
            },
            enabled = apage
        }
    },
    tab = _arc.option {
        x = { 42, 24 }, n = 1,
        sens = 1/16,
        options = 4,
        size = 3,
        lvl = { 0, 4, 15 },
    }
} :connect({ a = arc.connect() }, 120) -- refresh @ 120 fps instead of the default 30

function init() demo:init() end