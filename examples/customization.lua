-- custom affordances

include '../lib/nest_/core'
include '../lib/nest_/norns'
include '../lib/nest_/grid'

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