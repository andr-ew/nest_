util = { time = function() return 0 end }

dofile '/Users/instrument/Documents/code/nest_/nest_.lua'

grid = { connect = function() return { all = function() end } end }

_off = 0
_low = 4
_med = 8
_hi = 15

local _grid = _group:new()
nest_api.groups._screen = _group:new()
nest_api.groups._enc = _group:new()
nest_api.groups._key = _group:new()


----------------------------- controls time !

_grid.control = _control:new{
    x = 0,
    y = 0,
    lvl = { _off, _hi },
    edge = 1,
    draw_slew = 0,
    polyphony = -1,
    meta = {
        time = nil,
        events = {},
        matrix = {},
        last = nil,
        added = nil,
        removed = nil,
    }
}

_grid.control.input._.handlers = {
    point = function(self, z) end,
    line = function(self, v, z) end,
    plane = function(self, x, y, z) end
}

_grid.control.input._.handler = function(self, k, ...)
    self._.handlers[k](self, unpack(arg))
end

_grid.control.input._.check = function(self, groupidx, args)
    if(self._.groupidx == groupidx) then
        local contained = { x = false, y = false }
        local axis_val = { x = nil, y = nil }
        
        for i,v in ipairs{"x", "y"} do
            if type(self[v]) == "table" then 
                if #self[v] == 1 then
                    self[v] = self[v][1]
                    if self[v] == args[v] then 
                        contained[v] = true
                    end
                elseif #self[v] == 2 then
                    if  self[v][1] <= args[v] and args[v] <= self[v][2] then 
                        contained[v] = true
                        axis_val[v] = args[v] - self[v][1] + 1
                    end
                end
            else
                if self[v] == args[v] then 
                    contained[v] = true
                end
            end
        end
        
        if contained.x and contained.y then
            if axis_val.x == nil and axis_val.y == nil then
                return { "point", args.z }
            elseif axis_val.x ~= nil and axis_val.y ~= nil then
                return { "plane", axis_val.x, axis_val.y, args.z, self.x[2] -  self.x[1], self.y[2] -  self.y[1] }
            else
                if axis_val.x ~= nil then
                    return { "line", axis_val.x, args.z, self.x[2] -  self.x[1] }
                elseif axis_val.y ~= nil then
                    return { "line", axis_val.y, args.z, self.y[2] -  self.y[1] }
                end
            end
        else return nil end
    else return nil end
end

_grid.control.output._.handlers = {
    point = function(self) end,
    line_x = function(self) end,
    line_y = function(self) end,
    plane = function(self) end
}

_grid.control.output._.handler = function(self, k, ...)
    self._.handlers[k](self, unpack(arg))
end

_grid.control.output._.look = function(self, groupidx)
    if(self._.groupidx == groupidx) then
        local has_axis = { x = false, y = false }
        
        for i,v in ipairs{"x", "y"} do
            if type(self[v]) == "table" then 
                if #self[v] == 1 then
                elseif #self[v] == 2 then
                    has_axis[v] = true
                end
            end
        end
        
        if has_axis.x == false and has_axis.y == false then
            return { "point" }
        elseif has_axis.x and has_axis.y then
            return { "plane" }
        else
            if has_axis.x then
                return { "line_x" }
            elseif has_axis.y then
                return { "line_y" }
            end
        end
    else return nil end
end

_grid.metacontrol = _metacontrol:new{
    x = 0,
    y = 0,
    lvl = { _off, _hi },
    edge = 1,
    draw_slew = 0,
    polyphony = -1,
    meta = {
        time = nil,
        events = {},
        matrix = {},
        last = nil,
        added = nil,
        removed = nil,
    }
}

_grid.metacontrol.input._.handlers = {
    point = function(self, z) end,
    line = function(self, v, z, r) end,
    plane = function(self, x, y, z, rx, ry) end
}
_grid.metacontrol.input._.handler = _grid.control.input._.handler
_grid.metacontrol.input._.check = _grid.control.input._.check

_grid.metacontrol.output._.handlers = {
    point = function(self) end,
    line_x = function(self) end,
    line_y = function(self) end,
    plane = function(self) end
}
_grid.metacontrol.output._.handler = _grid.control.output._.handler
_grid.metacontrol.output._.look = _grid.control.output._.look

_grid.momentary = _grid.control:new()
_grid.momentary.input.handlers = {
    point = function(self, z)
        if self.edge == 1 then
            self.meta.last = self.value
            self.value = z
            self.meta.matrix[1] = self.value
            self:event(z, self.meta)
        elseif z == 0 then
            self.meta.time = util.time() - self.meta.events[1]
            self.meta.last = self.value
            self.value = z
            self.meta.matrix[1] = self.value
            self:event(z, self.meta)
            self.meta.events = {}
        else
            self.value = z
            self.meta.events[1] = util.time()
        end
    end,
    line = function(self, x, z, r)
        if self.edge == 1 and z == 1 then
            self.meta.last = self.value
            self.meta.added = x
            table.insert(self.value, x)
            if self.polyphony > -1 and #self.value > self.polyphony then
                table.remove(self.value, 1)
            end
            for i = 1, r do self.meta.matrix[i] = 0 end
            for i,v in ipairs(self.value) do self.meta.matrix[v] = 1
            self:event(self.value, self.meta)
        elseif self.edge == 1 and z == 0 then
            self.meta.last = self.value
            self.meta.removed = x
            self.meta.matrix[x] = 0
            for i,v in ipairs(self.value) do
                if v == x then 
                    table.remove(self.value, i)
                end
            end
            self:event(self.value, self.meta)
        elseif z == 1 then
            self.meta.last = self.value
            self.meta.added = x
            table.insert(self.value, x)
            if self.polyphony > -1 and #self.value > self.polyphony then
                table.remove(self.value, 1)
            end
            
            table.insert(self.meta.events, { x = x, z = 1, time = util.time() })
        else
            self.meta.last = self.value
            self.meta.removed = x
            for i,v in ipairs(self.value) do
                if v == x then table.remove(self.value, i) end
            end
                
            local done = true
            for i,v in ipairs(self.meta.events) do
                if v.x == x then v.z = 0 end
                if v.z == 1 then done = false end
            end
            
            if done then
                self.meta.time = util.time() - self.meta.events[1].time
                for i = 1, r do self.meta.matrix[i] = 0 end
                
                local ev = {}
                for i,v in ipairs(self.meta.events) do
                    ev[i] = v.x
                    self.meta.matrix[v.x] = 1
                end
                self:event(ev, self.meta)
                self.meta.events = {}
            end
        end
    end,
    plane = function(self, x, y, z, rx, ry)
        if self.edge == 1 and z == 1 then
            self.meta.last = self.value
            self.meta.added = { x = x, y = y }
            table.insert(self.value, { x = x, y = y })
            if self.polyphony > -1 and #self.value > self.polyphony then
                table.remove(self.value, 1)
            end
            for i = 1, rx do 
                self.meta.matrix[i] = {}
                for j = 1, ry do
                    self.meta.matrix[i][j] = 0
                end
            end
            for i,v in ipairs(self.value) do self.meta.matrix[v.x][v.y] = 1
            self:event(self.value, self.meta)
        elseif self.edge == 1 and z == 0 then
            self.meta.last = self.value
            self.meta.matrix[x][y] = 0
            self.meta.removed = { x = x, y = y }
            for i,v in ipairs(self.value) do
                if v.x == x and v.y == y then
                    table.remove(self.value, i)
                end
            end
            self:event(self.value, self.meta)
        elseif z == 1 then
            self.meta.last = self.value
            self.meta.added = { x = x, y = y }
            table.insert(self.value, x)
            if self.polyphony > -1 and #self.value > self.polyphony then
                table.remove(self.value, 1)
            end
            
            table.insert(self.meta.events, { x = x, y = y, z = 1, time = util.time() })
        else
            self.meta.last = self.value
            self.meta.removed = { x = x, y = y }
            for i,v in ipairs(self.value) do
                if v.x == x and v.y == y then
                    table.remove(self.value, i)
                end
            end
                
            local done = true
            for i,v in ipairs(self.meta.events) do
                if v.x == x and v.y == y then v.z = 0 end
                if v.z == 1 then done = false end
            end
            
            if done then
                self.meta.time = util.time() - self.meta.events[1].time
                        
                for i = 1, rx do 
                    self.meta.matrix[i] = {}
                    for j = 1, ry do
                        self.meta.matrix[i][j] = 0
                    end
                end
                
                local ev = {}
                for i,v in ipairs(self.meta.events) do
                    ev[i] = { x = v.x, y = v.x }
                    self.meta.matrix[v.x][v.y] = 1
                end
                self:event(ev, self.meta)
                self.meta.events = {}
            end
        end
    end
}

local ____mtrx__ = {}
        
_grid.momentary.output.handlers = {
    point = function(self)
        self:draw("led", self.x, self.y, self.lvl[self.value])
    end,
    line_x = function(self) 
        ____mtrx__ = {}
        for i = 1, self.x[2] - self.x[1] do ____mtrx__[i] = self.lvl[1] end
        for i,v in ipairs(self.value) do ____mtrx__[v] = self.lvl[2] end
        for i,v in ipairs(____mtrx__) do self:draw("led", i + self.x[1], self.y, v) end
    end,
    line_y = function(self) 
        ____mtrx__ = {}
        for i = 1, self.y[2] - self.y[1] do ____mtrx__[i] = self.lvl[1] end
        for i,v in ipairs(self.value) do ____mtrx__[v] = self.lvl[2] end
        for i,v in ipairs(____mtrx__) do self:draw("led", self.x, i + self.y[1], v) end
    end,
    plane = function(self) 
        ____mtrx__ = {}
        for i = 1, self.x[2] - self.x[1] do
            ____mtrx__[i] = {}
            for j = 1, self.y[2] - self.y[1] do 
                ____mtrx__[i][j] = self.lvl[1] 
            end
        end
        
        for i,v in ipairs(self.value) do ____mtrx__[v.x][v.y] = self.lvl[2] end
        
        for i,v in ipairs(____mtrx__) do 
            for j,v in ipairs(____mtrx__[i]) do 
                self:draw("led", i + self.x[1], j + self.y[1], v) 
            end
        end
    end
}

_grid.value = _grid.control:new()
_grid.value.input.handlers = {
    point = function(self, x, z)
        if self.edge == 1 and z == 1 then
            self.value = x
            self.meta.matrix[1] = 1
            self:event(self.value, self.meta)
        elseif z == 0 then
            self.meta.time = util.time() - self.meta.events[1]
            self.value = x
            self:event(self.value, self.meta)
            self.meta.events = {}
        else
            self.meta.events[1] = util.time()
        end
    end,
    line = function(self, x, z, r) 
        if self.edge == 1 and z == 1 then
            self.meta.last = self.value
            self.value = x
            for i = 1, r do self.meta.matrix[i] = self.value == i ? 1 : 0 end
            self:event(x, self.meta)
        elseif z == 1 then
--            self.value = v
            table.insert(self.meta.events, { x = x, z = 1, time = util.time() })
        else
            local done = true
            for i,v in ipairs(self.meta.events) do
                if v.x == x then v.z = 0 end
                if v.z == 1 then done = false end
            end
            
            if done then
                self.meta.time = util.time() - self.meta.events[1].time
                self.meta.last = self.value
                self.value = v
                for i = 1, r do self.meta.matrix[i] = self.value == i ? 1 : 0 end
                self:event(v, self.meta)
                self.meta.events = {}
            end
        end
    end,
    plane = function(self, x, y, z, rx, ry)
        if self.edge == 1 and z == 1 then
            self.meta.last = self.value
            self.value = { x = x, y = y }
            for i = 1, rx do 
                self.meta.matrix[i] = {}
                for j = 1, ry do
                    self.meta.matrix[i][j] = self.value.x == i and self.value.y == j ? 1 : 0 end
                end
            end
            self:event(self.value, self.meta)
        elseif z == 1 then
            table.insert(self.meta.events, { x = x, y = y, z = 1, time = util.time() })
        else
            local done = true
            for i,v in ipairs(self.meta.events) do
                if v.x == x and v.y == y then v.z = 0 end
                if v.z == 1 then done = false end
            end
            
            if done then
                self.meta.time = util.time() - self.meta.events[1].time
                self.meta.last = self.value
                self.value = { x, y }
                for i = 1, rx do 
                    self.meta.matrix[i] = {}
                    for j = 1, ry do
                        self.meta.matrix[i][j] = self.value.x == i and self.value.y == j ? 1 : 0 end
                    end
                end
                
                self:event(x, y, self.meta)
                self.meta.events = {}
            end
        end
    end
}
_grid.value.output.handlers = {
    point = function(self)
        self:draw("led", self.x, self.y, self.lvl[2])
    end,
    line_x = function(self) 
        for i = self.x[1], self.x[2] do
            self:draw("led", i, self.y, self.lvl[self.value == i - self.x[1] ? 2 : 1])
        end
    end,
    line_y = function(self) 
        for i = self.y[1], self.y[2] do
            self:draw("led", self.x, i, self.lvl[self.value == i - self.y[1] ? 2 : 1])
        end
    end,
    plane = function(self) 
        for i = self.x[1], self.x[2] do
            for j = self.y[1], self.y[2] do
                self:draw("led", i, j, self.lvl[self.value.x == i - self.x[1] and self.value.y == j - self.y[1] ? 2 : 1])
            end
        end
    end
}

function redraw()
    screen.clear()
    nest_api.roost:look(_screen.index)
    screen.update()
end

_screen.check = function() end
_screen.look = redraw
_screen.draw = function(self, method, ...)
    screen[method](unpack(arg))
end

for i = 1,4 do
    local grp = _grid:new()
    grp.handler = grid.connect(i)

    grp.look = function(self)
        self.handler:all(0)
        nest_api.roost:look(self.index)
        self.handler:refresh()
    end
    
    grp.handler.key = function(...)
        grp:check(arg)
    end
    
    nest_api.groups["_grid" .. tostring(i)] = grp
end

_grids = { _grid1, _grid2, _grid3, _grid4 }
_grid = _grid1

function key()
    _key:check(arg)
end

function enc(n,d)
    _enc:check(arg)
end

function init()
    nest_api:init()
end

function cleanup()
end