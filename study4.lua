-- nest_ study 4
-- state & meta-affordances

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

grid_nest = nest_ {
    pages = nest_ {
        nest_ {
            number = _grid.number {
                x = { 2, 6 },
                y = { 3, 6 },
                lvl = { 4, 15 },
                action = function(self, value)
                    print(self.key, self.value)
                end
            },
            pattern = _grid.pattern {
                x = { 2, 6 }, y = 7,
                count = 1, ----------- limit to 1 pattern playing or recording at a time
                target = function(self) return self.parent.number end
            },
            enabled = function(self)
                return (grid_nest.tab.value == self.key)
            end
        },
        nest_ {
            toggle = _grid.toggle {
                x = { 2, 6 },
                y = { 3, 6 },
                lvl = { 4, 15 },
                action = function(self, value)
                    print(self.key, self.value)
                end
            },
            preset = _grid.preset {
                x = { 2, 6 }, y = 7,
                target = function(self) return self.parent.toggle end
            },
            enabled = function(self)
                return (grid_nest.tab.value == self.key)
            end
        }
    },
    tab = _grid.number {
        x = { 1, 2 },
        y = 1,
        level = { 4, 15 },
        persistent = false,
    }
} :connect { g = grid.connect() }

function init()
    grid_nest:load()
    grid_nest:init()
end

function cleanup()
    grid_nest:save()
end