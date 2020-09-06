local _grid = _group:new()
_grid.deviceidx = 'g'

_grid.control = _control:new {
    v = 0,
    x = 1,
    y = 1,
    lvl = 15,
    inputs = { _input:new() },
    outputs = { _output:new() }
}


local input_contained = function(self)
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

    return contained.x and contained.y, axis_val
end

_grid.control.input._.update = function(self, deviceidx, args)
    if(self._.deviceidx == deviceidx) then
        if input_contained(self) then
            return args
        else return nil end
    else return nil end
end

_grid.metacontrol = _metacontrol:new {
    v = 0,
    x = 1,
    y = 1,
    lvl = 15,
    inputs = { _grid.control.input:new() },
    outputs = { _grid.control.output:new() }
}

_grid.muxcntrl = _grid.control:new()

_grid.muxcntrl.input._.handlers = {
    point = { function(self, z) end },
    line = { function(self, v, z) end },
    plane = { function(self, x, y, z) end }
}

_grid.muxcntrl.input._.handler = function(self, k, ...)
    self._.handlers[k](self, unpack(arg))
end

_grid.muxcntrl.input._.update = function(self, deviceidx, args)
    if(self._.deviceidx == deviceidx) then
        local contained, axis_val = input_contained(self)        

        if contained then
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

_grid.muxcntrl.output._.redraws = {
    point = function(self) end,
    line_x = function(self) end,
    line_y = function(self) end,
    plane = function(self) end
}

_grid.muxcntrl.output._.redraw = function(self, k, ...)
    self._.redraws[k](self, unpack(arg))
end

_grid.muxcntrl.output._.draw = function(self, deviceidx)
    if(self._.deviceidx == deviceidx) then
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

_grid.muxmetacntrl = _grid.metacontrol:new {
    inputs = { _grid.muxcntrl.input:new() }
    outputs = { _grid.muxcntrl.output:new() }
}

_grid.momentary = _grid.muxcntrl:new()
_grid.momentary.input.handlers = {
    point = {
    },
    line = {
    },
    plane = {
    }
}

local lvl = function(self, i)
    local x = self.lvl
    -- come back later and understand or not understand ? :)
    return (type(x) == 'number') and ((i > 1) and 0 or x) or (x[i] or x[i-1] or ((i > 1) and 0 or x[1]))
end

_grid.momentary.output.redraws = {
    point = function(self)
        self.g:led(self.x, self.y, lvl(self, self.v * 2 + 1))
    end,
    line_x = function(self)
        local mtrx = {}
        for i = 1, self.x[2] - self.x[1] do mtrx[i] = lvl(self, 3) end
        for i,v in ipairs(self.value) do mtrx[v] = lvl(self, 1) end
        for i,v in ipairs(mtrx) do self.g:led(i + self.x[1] - 1, self.y, v) end
    end,
    line_y = function(self)
        local mtrx = {}
        for i = 1, self.y[2] - self.y[1] do mtrx[i] = lvl(self, 3) end
        for i,v in ipairs(self.value) do mtrx[v] = lvl(self, 1) end
        for i,v in ipairs(mtrx) do self.g:led(self.x, i + self.y[1] - 1, v) end
    end,
    plane = function(self)
        local mtrx = {}
        for i = 1, self.x[2] - self.x[1] do
            mtrx[i] = {}
            for j = 1, self.y[2] - self.y[1] do
                mtrx[i][j] = lvl(self, 3)
            end
        end

        for i,v in ipairs(self.value) do mtrx[v.x][v.y] = lvl(self, 1) end

        for i,w in ipairs(mtrx) do
            for j,v in ipairs(w) do
                self.g:led(i + self.x[1] - 1, j + self.y[1] - 1, v)
            end
        end
    end
}

_grid.value = _grid.muxcntrl:new()
_grid.value.input.handlers = {
    point = {
    },
    line = {
    },
    plane = {
    }
}
_grid.value.output.redraws = {
    point = function(self)
        self.g:led(self.x, self.y, lvl(self, 1))
    end,
    line_x = function(self)
        for i = self.x[1], self.x[2] do
            self.g:led(i, self.y, lvl(self, (self.value == i - self.x[1]) and 1 or 3))
        end
    end,
    line_y = function(self)
        for i = self.y[1], self.y[2] do
            self.g:led(self.x, i, lvl(self, (self.value == i - self.y[1]) and 1 or 3))
        end
    end,
    plane = function(self)
        for i = self.x[1], self.x[2] do
            for j = self.y[1], self.y[2] do
                self.g:led(
                    i, j, 
                    lvl(
                        self, 
                        ((self.value.x == i - self.x[1]) and (self.value.y == j - self.y[1])) and 1 or 3
                    )
                )
            end
        end
    end
}

return _grid
