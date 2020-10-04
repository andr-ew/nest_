--[[

add .raw value to track keys that are actually held on grid

]]


local tab = require 'tabutil'

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

local input_contained = function(s, inargs)
    local contained = { x = false, y = false }
    local axis_val = { x = nil, y = nil }

    local args = { x = inargs[1], y = inargs[2] }

    for i,v in ipairs{"x", "y"} do
        if type(s[v]) == "table" then
            if #s[v] == 1 then
                s[v] = s[v][1]
                if s[v] == args[v] then
                    contained[v] = true
                end
            elseif #s[v] == 2 then
                if  s[v][1] <= args[v] and args[v] <= s[v][2] then
                    contained[v] = true
                    axis_val[v] = args[v] - s[v][1]
                end
            end
        else
            if s[v] == args[v] then
                contained[v] = true
            end
        end
    end

    return contained.x and contained.y, axis_val
end

_grid.control.input.update = function(s, deviceidx, args)
    if(s.deviceidx == deviceidx) then
        if input_contained(s, args) then
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

_grid.muxctrl = _grid.control:new()

_grid.muxctrl.input.handlers = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end },
    plane = { function(s, x, y, z) end }
}

_grid.muxctrl.input.handler = function(s, k, ...)
    s.handlers[k](s, ...)
end

_grid.muxctrl.input.update = function(s, deviceidx, args)
    if(s.deviceidx == deviceidx) then
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
    else return nil end
end

_grid.muxctrl.output.redraws = _obj_:new {
    point = function(s) end,
    line_x = function(s) end,
    line_y = function(s) end,
    plane = function(s) end
}

_grid.muxctrl.output.redraw = function(s, k)
    s.redraws[k](s)
end

_grid.muxctrl.output.draw = function(s, deviceidx)
    if(s.deviceidx == deviceidx) then
        local has_axis = { x = false, y = false }

        for i,v in ipairs{"x", "y"} do
            if type(s[v]) == "table" then
                if #s[v] == 1 then
                elseif #s[v] == 2 then
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
    inputs = { _grid.muxctrl.input:new() },
    outputs = { _grid.muxctrl.output:new() }
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
        s:a(s.v, t)
    end,
    line = function(s, x, y, z)
        local v = x - s.x[1] + 1
        if z > 0 then
            local rem = nil
            table.insert(s.v, v)
            if s.count and #s.v > s.count then rem = table.remove(s.v, 1) end
            s:a(s.v, v, rem) -- v, added, removed
        else
            local k = tab.key(s.v, v)
            if k then  
                table.remove(s.v, k)
                s:a(s.v, nil, v)
            end
        end
    end,
    plane = function(s, x, y, z) 
        local v = { x = x - s.x[1], y = y - s.y[1] }
        if z > 0 then
            local rem = nil
            table.insert(s.v, v)
            if s.count and #s.v > s.count then rem = table.remove(s.v, 1) end
            s:a(s.v, v, rem)
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
    local x = s.lvl
    -- come back later and understand or not understand ? :)
    return (type(x) == 'number') and ((i > 1) and 0 or x) or (x[i] or x[i-1] or ((i > 1) and 0 or x[1]))
end

_grid.momentary.output.redraws = _obj_:new {
    point = function(s)
        s.g:led(s.x, s.y, lvl(s, s.v * 2 + 1))
    end,
    line_x = function(s)
        local mtrx = {}
        for i = 1, s.x[2] - s.x[1] do mtrx[i] = lvl(s, 3) end
        for i,v in ipairs(s.v) do mtrx[v] = lvl(s, 1) end
        for i,v in ipairs(mtrx) do s.g:led(i + s.x[1] - 1, s.y, v) end
    end,
    line_y = function(s)
        local mtrx = {}
        for i = 1, s.y[2] - s.y[1] do mtrx[i] = lvl(s, 3) end
        for i,v in ipairs(s.v) do mtrx[v] = lvl(s, 1) end
        for i,v in ipairs(mtrx) do s.g:led(s.x, i + s.y[1] - 1, v) end
    end,
    plane = function(s)
        local mtrx = {}
        for i = 1, s.x[2] - s.x[1] do
            mtrx[i] = {}
            for j = 1, s.y[2] - s.y[1] do
                mtrx[i][j] = lvl(s, 3)
            end
        end

        for i,v in ipairs(s.v) do mtrx[v.x][v.y] = lvl(s, 1) end

        for i,w in ipairs(mtrx) do
            for j,v in ipairs(w) do
                s.g:led(i + s.x[1] - 1, j + s.y[1] - 1, v)
            end
        end
    end
}

-- if count then actions fire on key up
_grid.value = _grid.muxctrl:new()
_grid.value.input.handlers = _obj_:new {
    point = function(s, x, y, z) 
        if z > 0 then s:a(s.v) end
    end,
    line = function(s, x, y, z) 
        if z > 0 then
            --local last = s.v
            s.v = x - s.x[1]
            s:a(s.v)--, last)
        end
    end,
    plane = function(s, x, y, z) 
        if z > 0 then
            --local last = s.v
            s.v = { x = x - s.x[1], y = y - s.y[1] }
            s:a(s.v)--, last)
        end
    end
}
_grid.value.output.redraws = _obj_:new {
    point = function(s)
        s.g:led(s.x, s.y, lvl(s, 1))
    end,
    line_x = function(s)
        for i = s.x[1], s.x[2] do
            s.g:led(i, s.y, lvl(s, (s.v == i - s.x[1]) and 1 or 3))
        end
    end,
    line_y = function(s)
        for i = s.y[1], s.y[2] do
            s.g:led(s.x, i, lvl(s, (s.v == i - s.y[1]) and 1 or 3))
        end
    end,
    plane = function(s)
        for i = s.x[1], s.x[2] do
            for j = s.y[1], s.y[2] do
                s.g:led(i, j, lvl(s, ((s.v.x == i - s.x[1]) and (s.v.y == j - s.y[1])) and 1 or 3))
            end
        end
    end
}

return _grid
