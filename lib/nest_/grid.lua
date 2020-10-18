local tab = require 'tabutil'

_grid = _device:new()
_grid.devk = 'g'

_grid.control = _control:new {
    v = 0,
    x = 1,
    y = 1,
    lvl = 15,
    input = _input:new(),
    output = _output:new()
}

local input_contained = function(s, inargs)
    local contained = { x = false, y = false }
    local axis_size = { x = nil, y = nil }

    local args = { x = inargs[1], y = inargs[2] }

    for i,v in ipairs{"x", "y"} do
        if type(s.p_[v]) == "table" then
            if #s.p_[v] == 1 then
                s[v] = s.p_[v][1]
                if s.p_[v] == args[v] then
                    contained[v] = true
                end
            elseif #s.p_[v] == 2 then
                if  s.p_[v][1] <= args[v] and args[v] <= s.p_[v][2] then
                    contained[v] = true
                end
                axis_size[v] = s.p_[v][2] - s.p_[v][1] + 1
            end
        else
            if s.p_[v] == args[v] then
                contained[v] = true
            end
        end
    end

    return contained.x and contained.y, axis_size
end

_grid.control.input.filter = function(s, args)
    if input_contained(s, args) then
        return args
    else return nil end
end

_grid.metacontrol = _metacontrol:new {
    v = 0,
    x = 1,
    y = 1,
    lvl = 15,
    input = _input:new(),
    output = _output:new()
}

_grid.muxcontrol = _grid.control:new()

-- update -> filter -> handler -> muxhandler -> muxfilter -> action -> v

-- stop the chain if muxhandler returns nil or some other value. this might need some changes to core ? what if the user just doesn't feel like returning a value from handler?

_grid.muxcontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end },
    plane = { function(s, x, y, z) end }
}

_grid.muxcontrol.input.muxfilter = _obj_:new {
    point = function(s, ...) return ... end,
    line = function(s, ...) return ... end,
    plane = function(s, ...) return ... end
}


_grid.muxcontrol.input.handler = function(s, k, ...)
    return s.muxfilter[k](s, s.muxhandler[k](s, ...))
end

_grid.muxcontrol.input.filter = function(s, args)
    local contained, axis_size = input_contained(s, args)

    if contained then
        if axis_size.x == nil and axis_size.y == nil then
            return { "point", args[1], args[2], args[3] }
        elseif axis_size.x ~= nil and axis_size.y ~= nil then
            return { "plane", args[1], args[2], args[3] }
        else
            if axis_size.x ~= nil then
                return { "line", args[1], args[2], args[3] }
            elseif axis_size.y ~= nil then
                return { "line", args[2], args[1], args[3] }
            end
        end
    else return nil end
end

_grid.muxcontrol.output.redraws = _obj_:new {
    point = function(s) end,
    line_x = function(s) end,
    line_y = function(s) end,
    plane = function(s) end
}

_grid.muxcontrol.output.redraw = function(s, devk)
    local has_axis = { x = false, y = false }

    for i,v in ipairs{"x", "y"} do
        if type(s.p_[v]) == "table" then
            if #s.p_[v] == 1 then
            elseif #s.p_[v] == 2 then
                has_axis[v] = true
            end
        end
    end

    if has_axis.x == false and has_axis.y == false then
        s.redraws.point(s)
    elseif has_axis.x and has_axis.y then
        s.redraws.plane(s)
    else
        if has_axis.x then
            s.redraws.line_x(s)
        elseif has_axis.y then
            s.redraws.line_y(s)
        end
    end
end

_grid.muxmetacntrl = _grid.metacontrol:new {
    input = _grid.muxcontrol.input:new(),
    output = _grid.muxcontrol.output:new()
}

_grid.momentary = _grid.muxcontrol:new({ count = nil, held = {}, matrix = {} })

_grid.momentary.new = function(self, o) 
    o = _grid.muxcontrol.new(self, o)

    local _, axis = input_contained(o, { -1, -1 })
    
    local v --matrix
    
    if axis.x and axis.y then 
        v = {}
        o.v = type(o.v) == 'table' and o.v or {}
        for x = 1, axis.x do 
            v[x] = {}
            for y = 1, axis.y do
                v[x][y] = 0
            end
        end
    elseif axis.x or axis.y then
        v = {}
        o.v = type(o.v) == 'table' and o.v or {}
        for i = 1, (axis.x or axis.y) do 
            v[i] = 0
        end
    else 
        v = o.v
    end

    o:replace('matrix', v)
    
    return o
end

local function count(s) 
    local min = 0
    local max = nil

    if type(s.p_.count) == "table" then 
        max = s.p_.count[#s.p_.count]
        min = #s.p_.count > 1 and s.p_.count[1] or 0
    else max = s.p_.count end

    return min, max
end

_grid.momentary.input.muxhandler = _obj_:new {
    point = function(s, x, y, z) --
        s.v = z
        local t = nil
        if z > 0 then s.time = util.time()
        else t = util.time() - s.time end
        return s.v, t
    end,
    line = function(s, x, y, z)
        local min, max = count(s)
        local i = x - s.p_.x[1] + 1
        local add
        local rem

        if z > 0 then
            add = i
            table.insert(s.v, i)
            if s.p_.count and #s.held > s.p_.count then rem = table.remove(s.held, 1) end
        else
            local k = tab.key(s.held, i)
            if k then
                rem = table.remove(s.held, k)
            end
        end

        if add then s.matrix[add] = 1 end
        if rem then s.matrix[rem] = 0 end
   
        -- only proceed through the reset of the chain if #held > min, use a nil return here to stop the chain
        return s.held, add, rem, s.matrix
    end,
    plane = function(s, x, y, z) 
        local v = { x = x - s.p_.x[1], y = y - s.p_.y[1] }
        if z > 0 then
            local rem = nil
            table.insert(s.v, v)
            if s.p_.count and #s.v > s.p_.count then rem = table.remove(s.v, 1) end
            return s.v, v, rem
        else
            for i,w in ipairs(s.v) do
                if w.x == v.x and w.y == v.y then 
                    table.remove(s.v, i)
                    return s.v, nil, v
                end
            end
        end
    end
}

--nothing for momentary ?
_grid.momentary.input.muxfilter = _obj_:new {
    point = function(s, ...) return ... end,
    line = function(s, ...) return s, ... end,
    plane = function(s, ...) return ... end
}

local lvl = function(s, i)
    local x = s.p_.lvl
    -- come back later and understand or not understand ? :)
    return (type(x) == 'number') and ((i > 1) and 0 or x) or (x[i] or x[i-1] or ((i > 1) and 0 or x[1]))
end

_grid.momentary.output.redraws = _obj_:new {
    point = function(s)
        s.g:led(s.p_.x, s.p_.y, lvl(s, s.v * 2 + 1))
    end,
    line_x = function(s)
        local mtrx = {}
        for i = 1, s.p_.x[2] - s.p_.x[1] do mtrx[i] = lvl(s, 3) end
        for i,v in ipairs(s.v) do mtrx[v] = lvl(s, 1) end
        for i,v in ipairs(mtrx) do s.g:led(i + s.p_.x[1] - 1, s.p_.y, v) end
    end,
    line_y = function(s)
        local mtrx = {}
        for i = 1, s.p_.y[2] - s.p_.y[1] do mtrx[i] = lvl(s, 3) end
        for i,v in ipairs(s.v) do mtrx[v] = lvl(s, 1) end
        for i,v in ipairs(mtrx) do s.g:led(s.p_.x, i + s.p_.y[1] - 1, v) end
    end,
    plane = function(s)
        local mtrx = {}
        for i = 1, s.p_.x[2] - s.p_.x[1] do
            mtrx[i] = {}
            for j = 1, s.p_.y[2] - s.p_.y[1] do
                mtrx[i][j] = lvl(s, 3)
            end
        end

        for i,v in ipairs(s.v) do mtrx[v.x][v.y] = lvl(s, 1) end

        for i,w in ipairs(mtrx) do
            for j,v in ipairs(w) do
                s.g:led(i + s.p_.x[1] - 1, j + s.p_.y[1] - 1, v)
            end
        end
    end
}

-- if count then actions fire on key up
_grid.value = _grid.muxcontrol:new()
_grid.value.input.muxhandler = _obj_:new {
    point = function(s, x, y, z) 
        if z > 0 then return s.v end
    end,
    line = function(s, x, y, z) 
        if z > 0 then
            s.v = x - s.p_.x[1]
            return s.v
        end
    end,
    plane = function(s, x, y, z) 
        if z > 0 then
            s.v = { x = x - s.p_.x[1], y = y - s.p_.y[1] }
            return s.v
        end
    end
}
_grid.value.output.redraws = _obj_:new {
    point = function(s)
        s.g:led(s.p_.x, s.p_.y, lvl(s, 1))
    end,
    line_x = function(s)
        for i = s.p_.x[1], s.p_.x[2] do
            s.g:led(i, s.p_.y, lvl(s, (s.v == i - s.p_.x[1]) and 1 or 3))
        end
    end,
    line_y = function(s)
        for i = s.p_.y[1], s.p_.y[2] do
            s.g:led(s.p_.x, i, lvl(s, (s.v == i - s.p_.y[1]) and 1 or 3))
        end
    end,
    plane = function(s)
        for i = s.x[1], s.x[2] do
            for j = s.p_.y[1], s.p_.y[2] do
                s.g:led(i, j, lvl(s, ((s.v.x == i - s.p_.x[1]) and (s.v.y == j - s.p_.y[1])) and 1 or 3))
            end
        end
    end
}

return _grid
