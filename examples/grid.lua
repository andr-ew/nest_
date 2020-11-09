-- paginated demo of each standard control type included in the grid module

function stringrow(i) 
    o = ""
    for _,v in ipairs(i) do o = o .. v .. " " end
    return o
end

function print_matrix_1d(v) print(stringrow(v)) end

function print_matrix_2d(v) 
    for _,row in ipairs(v) do print_matrix_1d(row) end
end

include 'nest_/lib/nest_/core'
include 'nest_/lib/nest_/norns'
include 'nest_/lib/nest_/grid'

n = nest_ {
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
            enabled = function(self) return n.tab.v + 1 == self.k end
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
            enabled = function(self) return n.tab.v + 1 == self.k end
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
            enabled = function(self) return n.tab.v + 1 == self.k end
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
            enabled = function(self) return n.tab.v + 1 == self.k end
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
            enabled = function(self) return n.tab.v + 1 == self.k end
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
            enabled = function(self) return n.tab.v + 1 == self.k end
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
            enabled = function(self) return n.tab.v + 1 == self.k end
        }
    }
} :connect {
    g = grid.connect()
}
