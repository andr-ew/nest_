-- nest_ study 3
-- affordance overview
--
-- (docs on github)

include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'
include 'lib/nest/txt'
include 'lib/nest/arc'

-------------------------------------------------utility functions

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
                level = 15
            }, 
            fill_1d = _grid.fill {
                x = { 1, 7 },
                y = 5,
                level = 15
            },
            fill_2d = _grid.fill {
                x = { 9, 15 },
                y = { 2, 8 },
                level = 15
            }
        },
        -----------------------------------------number
        nest_ {
            number_0d = _grid.number {
                x = 1,
                y = 3,
                level = { 4, 15 },
                action = gridaction
            }, 
            number_1d = _grid.number {
                x = { 1, 7 },
                y = 5,
                level = { 4, 15 },
                action =  gridaction
            }, 
            number_2d = _grid.number {
                x = { 9, 15 },
                y = { 2, 8 },
                level = { 4, 15 },
                action = gridaction
            }
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
                min = 0, max = 1,
                action = gridaction
            }, 
            control_2d = _grid.control {
                x = { 9, 15 },
                y = { 2, 8 },
                min = -1, max = 1,
                action = gridaction
            }
        },
        -----------------------------------------trigger
        nest_ {
            trigger_0d = _grid.trigger {
                x = 1,
                y = 3,
                level = grid_trigger_level,
                action = gridaction
            }, 
            trigger_1d = _grid.trigger {
                x = { 1, 7 },
                y = 5,
                level = grid_trigger_level,
                action = gridaction
            }, 
            trigger_2d = _grid.trigger {
                x = { 9, 15 },
                y = { 2, 8 },
                level = grid_trigger_level,
                action = gridaction
            }
        },
        -----------------------------------------toggle
        nest_ {
            toggle_0d = _grid.toggle {
                x = 1,
                y = 3,
                level = { 4, 15 },
                action = gridaction
            }, 
            toggle_1d = _grid.toggle {
                x = { 1, 7 },
                y = 5,
                level = { 4, 15 },
                action = gridaction
            }, 
            toggle_2d = _grid.toggle {
                x = { 9, 15 },
                y = { 2, 8 },
                level = { 4, 15 },
                action = gridaction
            }
        },
        -----------------------------------------momentary
        nest_ {
            momentary_0d = _grid.momentary {
                x = 1,
                y = 3,
                level = { 4, 15 },
                action = gridaction
            }, 
            momentary_1d = _grid.momentary {
                x = { 1, 7 },
                y = 5,
                level = { 4, 15 },
                action = gridaction
            }, 
            momentary_2d = _grid.momentary {
                x = { 9, 15 },
                y = { 2, 8 },
                level = { 4, 15 },
                action = gridaction
            }
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
            }
        }
    } :each(function(i, v)
        v.enabled = function(self) 
            return demo.grid.tab.value == self.k end
    end),
    tab = _grid.number {
        x = { 1, 7 },
        y = 1,
        level = { 4, 15 }
    }
} :connect {
    g = grid.connect()
}

-------------------------------------------------txt (keys, encoders, screen)

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
                min = 1, max = 8, value = 1,
                inc = 1, step = 1,
                wrap = true,
                align = { 'left', 'bottom' },
                action = function(self, value) print(self.k, value) end
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
                level = { 15, 0 },
                fill = { 0, 15 },
                border = 15,
                edge = 0,
                action = function(self, value) print(self.k, value) end
            }
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
                level = 0,
                fill = 15,
                value = { "one", "two", "three" }
            },
            label3 = _txt.label {
                x = { 46, 128 - 2 }, y = 44,
                level = { 15, 7, 2 },
                value = { "four", "five", "six" }
            },
            label4 = _txt.label {
                x = 128 - 2, y = 64 - 4,
                margin = 8,
                align = { 'right', 'bottom' },
                level = { 2, 7, 15 },
                value = { "seven", "eight", "nine" }
            },
            label5 = _txt.label {
                x = 128 - 2, y = 14,
                flow = 'y',
                align = 'right',
                --level = 7,
                value = { "ten", "eleven", "twelve" }
            },
            label6 = _txt.label {
                x = { 2, 44 - 4 },
                y = { 38, 64 - 2 },
                border = 15,
                value = "button"
            }
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
            }
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
        }
    } :each(function(i, v)
        v.enabled = function(self) return demo.txt.tab.options[demo.txt.tab.value // 1] == self.k end
    end),
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

---------------------------------------------arc

demo.arc = nest_ {
    page = nest_ {
        -------------------------------------fill & delta
        nest_ {
            fill1 = _arc.fill {
                n = 2,
                v = 1/64,
                level = 15
            },
            fill2 = _arc.fill {
                n = 3,
                v = { 0.2, 0.5 },
                level = 7
            },
            fill3 = _arc.fill {
                n = 4,
                v = { 0, 4, 7, 15, 0, 4, 7, 15 }
            },
            delta = _arc.delta {
                n = 2,
                action = function(self, d) print(self.k, d) end
            }
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
                min = 0.2, max = 0.4,
                wrap = true,
                action = function(self, value) print(self.k, value) end
            },
            number3 = _arc.number {
                n = 4,
                sens = 2,
                min = -math.huge, 
                max = math.huge,
                cycle = 20,
                action = function(self, value) print(self.k, value) end
            }
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
                min = -1, max = 1,
                action = function(self, value) print(self.k, value) end
            },
            control3 = _arc.control {
                n = 4,
                x = { 40, 40 + 12 },
                sens = 1,
                level = { 4, 4, 15 },
                action = function(self, value) print(self.k, value) end
            }
        },
        -------------------------------------option
        nest_ {
            option1 = _arc.option {
                x = { 42, 24 },
                n = 2,
                sens = 1/16,
                min = 1, max = 4,
                size = { 1, 2, 4, 8, 16 },
                margin = 1,
                level = { 0, 4, 15 },
                action = function(s, v) print(math.floor(v)) end
            },
            option2 = _arc.option {
                --x = { 42, 24 },
                n = 3,
                sens = 1/16,
                include = { 1, 2, 4 },
                size = 4,
                margin = 0,
                level = { 0, 4, 15 },
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
            }
        }
    } :each(function(i, v)
        v.enabled = function(self) return demo.arc.tab.value // 1 == self.k end
    end),
    tab = _arc.option {
        x = { 42, 24 }, n = 1,
        sens = 1/16,
        options = 4,
        size = 3,
        level = { 0, 4, 15 },
    }
} :connect({ a = arc.connect() }, 120) -- refresh @ 120 fps instead of the default 30

function init() demo:init() end
