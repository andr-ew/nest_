-- paginated demos of affordances included in nest_ 

function r()
    norns.script.load(norns.state.script)
end

function stringrow(i) 
    o = ""
    for _,v in ipairs(i) do o = o .. v .. " " end
    return o
end

function print_matrix_1d(v) print(stringrow(v)) end

function print_matrix_2d(v) 
    for _,row in ipairs(v) do print_matrix_1d(row) end
end

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'

local function gpage(self) return g.tab.value + 1 == self.k end
local function tpage(self) return t.tab.options[t.tab.value] == self.k end

-------------------------------------------------grid

g = nest_ {
    tab = _grid.number {
        x = { 1, 7 },
        y = 1,
        lvl = { 4, 15 }
    },
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
                action = function(self, value) 
                    print(self.k, value) 
                end
            }, 
            number_1d = _grid.number {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k, value) 
                end
            }, 
            number_2d = _grid.number {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k) 
                    tab.print(value)
                end
            },
            enabled = gpage
        },
        -----------------------------------------fader
        nest_ {
            fader_0d = _grid.fader {
                x = 1,
                y = 3,
                action = function(self, value) 
                    print(self.k, value) 
                end
            }, 
            fader_1d = _grid.fader {
                x = { 1, 7 },
                y = 5,
                range = { -1, 1 },
                action = function(self, value) 
                    print(self.k, value) 
                end
            }, 
            fader_2d = _grid.fader {
                x = { 9, 15 },
                y = { 2, 8 },
                range = { -1, 1 },
                action = function(self, value) 
                    print(self.k) 
                    tab.print(value)
                end
            },
            enabled = gpage
        },
        -----------------------------------------trigger
        nest_ {
            trigger_0d = _grid.trigger {
                x = 1,
                y = 3,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k, "1") 
                end
            }, 
            trigger_1d = _grid.trigger {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k)
                    print_matrix_1d(value)
                end
            }, 
            trigger_2d = _grid.trigger {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k) 
                    print_matrix_2d(value)
                end
            },
            enabled = gpage
        },
        -----------------------------------------toggle
        nest_ {
            toggle_0d = _grid.toggle {
                x = 1,
                y = 3,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k, v) 
                end
            }, 
            toggle_1d = _grid.toggle {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k)
                    print_matrix_1d(value)
                end
            }, 
            toggle_2d = _grid.toggle {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k) 
                    print_matrix_2d(value)
                end
            },
            enabled = gpage
        },
        -----------------------------------------momentary
        nest_ {
            momentary_0d = _grid.momentary {
                x = 1,
                y = 3,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k, v) 
                end
            }, 
            momentary_1d = _grid.momentary {
                x = { 1, 7 },
                y = 5,
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k)
                    print_matrix_1d(value)
                end
            }, 
            momentary_2d = _grid.momentary {
                x = { 9, 15 },
                y = { 2, 8 },
                lvl = { 4, 15 },
                action = function(self, value) 
                    print(self.k) 
                    print_matrix_2d(value)
                end
            },
            enabled = gpage
        },
        -----------------------------------------range
        nest_ {
            range_0d = _grid.range {
                x = 1,
                y = 3,
                action = function(self, value) 
                    print(self.k, v) 
                end
            }, 
            range_1d = _grid.range {
                x = { 1, 7 },
                y = 5,
                action = function(self, value) 
                    print(self.k)
                    tab.print(value)
                end
            }, 
            range_2d = _grid.range {
                x = { 9, 15 },
                y = { 2, 8 },
                action = function(self, value) 
                    print(self.k) 
                    tab.print(value[1])
                    tab.print(value[2])
                end
            },
            enabled = gpage
        }
    }
} :connect {
    g = grid.connect()
}

---------------------------------------------txt

t = nest_ {
    page = nest_ {
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
        input = nest_ {
            --[[
            trigger = _txt.key.trigger {
                x = 2, y = 14,
                n = 1,
                action = function(self, value) print(self.k, 'bang') end
            },
            --]]
            number = _txt.enc.number {
                x = 2, y = 32,
                n = 2,
                range = { 1, 8 },
                wrap = true,
                align = { 'left', 'bottom' },
                action = function(self, value) print(self.k, value) end
            },
            control = _txt.enc.control {
                x = 64, y = 32,
                n = 3,
                controlspec = controlspec.BIPOLAR,
                align = { 'left', 'bottom' },
                action = function(self, value) print(self.k, value) end
            },
            momentary = _txt.key.momentary {
                x = 2, y = 46, 
                n = 2,
                action = function(self, value) print(self.k, value) end
            },
            toggle = _txt.key.toggle {
                x = 64, y = 42, 
                n = 3,
                padding = 4,
                lvl = { 15, 0 },
                fill = { 0, 15 },
                border = 15,
                edge = 0,
                action = function(self, value) print(self.k, value) end
            },
            enabled = tpage
        }
    },
    tab = _txt.enc.option {
        x = 2, y = 2, n = 1, margin = 6,
        options = {
            "label",
            "input",
            "option",
            "list"
        }
    }
} :connect {
    key = key,
    enc = enc,
    screen = screen
}
