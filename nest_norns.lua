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
    lvl = _hi,
    offlvl = _off,
    edge = 1,
    draw_slew = 0,
    polyphony = -1,
    meta = {
        real = {},
        time = 0,
        events = {},
        matrix = {},
        last = nil,
        added = nil,
        removed = nil,
    }
}

_grid.control.input._.handler = {
    point = function(z) end,
    line = function(v, z) end,
    plane = function(x, y, z) end
}

_grid.control.input._.check = function(self, groupidx, args)
    if(self._.groupidx == groupidx) then
        local contained = { x = false, y = false }
        local axis_val = { x = nil, y = nil }
        
        for i,v in ipairs{"x", "y"} do
            if type(self[v]) == "table" then 
                if #self[v] == 1 then
                    if self[v] == args[v] then 
                        contained[v] = true
                    end
                elseif #self[v] == 2 then
                    if  self[v][1] <= args[v] and args[v] <= self[v][2] then 
                        contained[v] = true
                        axis_val[v] = args[v] - self[v][1]
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
                self._.handler.point(self, args.z)
            elseif axis_val.x ~= nil and axis_val.y ~= nil then
                self._.handler.plane(self, axis_val.x, axis_val.y, args.z)
            else
                if axis_val.x ~= nil then
                    self._.handler.line(self, axis_val.x, args.z)
                elseif axis_val.y ~= nil then
                    self._.handler.line(self, axis_val.y, args.z)
                end
            end
        else return false end
    else return false end
end

_grid.control.output._.handler = {
    point = function(self) end,
    line_x = function(self) end,
    line_y = function(self) end,
    plane = function(self) end
}

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
            self._.handler.point(self, args.z)
        elseif has_axis.x and has_axis.y then
            self._.handler.plane(self)
        else
            if has_axis.x then
                self._.handler.line_x(self)
            elseif has_axis.y then
                self._.handler.line_y(self)
            end
        end
        
        return true
    else return false end
end

_grid.metacontrol = _metacontrol:new{
    x = 0,
    y = 0,
    lvl = _hi,
    offlvl = _off,
    edge = 1,
    draw_slew = 0,
    polyphony = -1,
    meta = {
        real = {},
        time = 0,
        events = {},
        matrix = {},
        last = nil,
        added = nil,
        removed = nil,
    }
}

_grid.metacontrol.input._.handler = {
    point = function(z) end,
    line = function(v, z) end,
    plane = function(x, y, z) end
}

_grid.metacontrol.input._.check = _grid.control.input._.check

_grid.metacontrol.output._.handler = {
    point = function(self) end,
    line_x = function(self) end,
    line_y = function(self) end,
    plane = function(self) end
}

_grid.metacontrol.output._.look = _grid.control.output._.look

-----------------------------

_grid.value = _grid.control:new()

-----------------------------

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
    
    grp.key = function() 
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