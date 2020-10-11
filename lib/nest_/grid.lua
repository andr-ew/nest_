--[[

add .raw value to track keys that are actually held on grid

_grid.trigger ?
_grid.rect ?

_grid.momentary -> _grid.gate ?

]]

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
    local axis_val = { x = nil, y = nil }

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
                    axis_val[v] = args[v] - s.p_[v][1]
                end
            end
        else
            if s.p_[v] == args[v] then
                contained[v] = true
            end
        end
    end

    return contained.x and contained.y, axis_val
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

_grid.muxctrl = _grid.control:new()

_grid.muxctrl.input.handlers = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end },
    plane = { function(s, x, y, z) end }
}

_grid.muxctrl.input.handler = function(s, k, ...)
    s.handlers[k](s, ...)
end

_grid.muxctrl.input.filter = function(s, args)
    local contained, axis_val = input_contained(s, args)

    if contained then
        if axis_val.x == nil and axis_val.y == nil then
            return { "point", args[1], args[2], args[3] }
        elseif axis_val.x ~= nil and axis_val.y ~= nil then
            return { "plane", args[1], args[2], args[3] }
        else
            if axis_val.x ~= nil then
                return { "line", args[1], args[2], args[3] }
            elseif axis_val.y ~= nil then
                return { "line", args[2], args[1], args[3] }
            end
        end
    else return nil end
end

_grid.muxctrl.output.redraws = _obj_:new {
    point = function(s) end,
    line_x = function(s) end,
    line_y = function(s) end,
    plane = function(s) end
}

_grid.muxctrl.output.redraw = function(s, devk)
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
    input = _grid.muxctrl.input:new(),
    output = _grid.muxctrl.output:new()
}

-- add support for count = { high, low }, low presses must be stored somehow but will not change v or call a(). the t sent tracks from the first key down

-- use init() to ensure v has initialized properly

_grid.momentary = _grid.muxctrl:new({ count = nil })
_grid.momentary.input.handlers = _obj_:new {
    point = function(s, x, y, z)
        s.v = z
        local t = nil
        if z > 0 then s.time = util.time()
        else t = util.time() - s.time end
        s:action(s.v, t)
    end,
    line = function(s, x, y, z)
        local v = x - s.p_.x[1] + 1
        if z > 0 then
            local rem = nil
            table.insert(s.v, v)
            if s.p_.count and #s.v > s.p_.count then rem = table.remove(s.v, 1) end
            s:action(s.v, v, rem) -- v, added, removed
        else
            local k = tab.key(s.v, v)
            if k then  
                table.remove(s.v, k)
                s:action(s.v, nil, v)
            end
        end
    end,
    plane = function(s, x, y, z) 
        local v = { x = x - s.p_.x[1], y = y - s.p_.y[1] }
        if z > 0 then
            local rem = nil
            table.insert(s.v, v)
            if s.p_.count and #s.v > s.p_.count then rem = table.remove(s.v, 1) end
            s:action(s.v, v, rem)
        else
            for i,w in ipairs(s.v) do
                if w.x == v.x and w.y == v.y then 
                    table.remove(s.v, i)
                    s.a(s.v, nil, v)
                end
            end
        end
    end
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
_grid.value = _grid.muxctrl:new()
_grid.value.input.handlers = _obj_:new {
    point = function(s, x, y, z) 
        if z > 0 then s:action(s.v) end
    end,
    line = function(s, x, y, z) 
        if z > 0 then
            --local last = s.v
            s.v = x - s.p_.x[1]
            s:action(s.v)--, last)
        end
    end,
    plane = function(s, x, y, z) 
        if z > 0 then
            --local last = s.v
            s.v = { x = x - s.p_.x[1], y = y - s.p_.y[1] }
            s:action(s.v)--, last)
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
