-- nest_ study 2
-- the grid & multiples

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

-- a grid nest structure
grid_nest = nest_ {
    pages = nest_ {
        nest_ {
            -- (we're just using the default initial values for these, so there's no need to supply value)
            toggle = _grid.toggle {
                x = 2,
                y = 3,
                level = { 4, 15 },
                action = function(self, value) 
                    print(self.key, value) 
                end
            },
            number = _grid.number {
                x = { 4, 8 },
                y = 3,
                level = { 4, 15 },
                action = function(self, value) 
                    print(self.key, value) 
                end
            },
            toggle2 = _grid.toggle {
                x = { 2, 4 },
                y = { 5, 7 },
                level = { 4, 15 },
                action = function(self, value) 
                    print(self.key, value) 
                end
            },
            enabled = function(self)
                return (grid_nest.tab.value == 1)
            end
        },
        nest_ {
            numbers = nest_(16):each(function(i)
                return _grid.number {
                    x = i,
                    y = { 2, 8 },
                    value = math.random(1, 7), -- initialize every value with a random number, just for fun
                    action = function(self, value) 
                        print("numbers[" ..i .. "]", value)
                    end
                }
            end),
            enabled = function(self)
                return (grid_nest.tab.value == 2)
            end
        }
    },
    tab = _grid.number {
        x = { 1, 2 },
        y = 1,
        level = { 4, 15 },
    }
}

-- connect the nest to a grid device
grid_nest:connect {
    g = grid.connect()
}

-- initialize the nest
function init()
    grid_nest:init()
end