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

_grid.muxcontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end },
    plane = { function(s, x, y, z) end }
}

-- muxfilter is kind of unnecesary, we can just run the momentary functions when we need them inside toggle, trigger
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

_grid.momentary = _grid.muxcontrol:new({ count = nil, held = {}, tdown = {}, tlast = {}, theld = {}, list = {} })

_grid.momentary.new = function(self, o) 
    o = _grid.muxcontrol.new(self, o)

    local _, axis = input_contained(o, { -1, -1 })
    
    local v
    
    if axis.x and axis.y then 
        v = {}
        for x = 1, axis.x do 
            v[x] = {}
            for y = 1, axis.y do
                v[x][y] = 0
            end
        end
    elseif axis.x or axis.y then
        v = {}
        for i = 1, (axis.x or axis.y) do 
            v[i] = 0
        end
    else 
        v = 0
    end

    if type(v) ~= type(o.v) then o:replace('v', v) end
    o:replace('held', type(v) == 'table' and o.v:new() or o.v)
    o:replace('tdown', type(v) == 'table' and o.v:new() or o.v)
    o:replace('theld', type(v) == 'table' and o.v:new() or o.v)
    o:replace('tlast', type(v) == 'table' and o.v:new() or o.v)
    
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
        if z > 0 then 
            s.tlast = s.tdown
            s.tdown = util.time()
        else s.theld = util.time() - s.tdown end
        return z, s.theld
    end,
    line = function(s, x, y, z)
        local i = x - s.p_.x[1] + 1
        local min, max = count(s)
        local add
        local rem

        if z > 0 then
            add = i
            s.tlast[i] = s.tdown[i]
            s.tdown[i] = util.time()
            table.insert(s.list, i)
            if max and #s.list > max then rem = table.remove(s.list, 1) end
        else
            local k = tab.key(s.list, i)
            if k then
                rem = table.remove(s.list, k)
            end
            s.theld[i] = util.time() - s.tdown[i]
        end

        if add then s.held[add] = 1 end
        if rem then s.held[rem] = 0 end
   
        if #s.held > min then return s.held, add, rem end
    end,
    plane = function(s, x, y, z) 
        local i = { x = x - s.p_.x[1] + 1, y = y - s.p_.y[1] + 1 }
        local min, max = count(s)
        local add
        local rem

        if z > 0 then
            add = i
            s.tlast[i.x][i.y] = s.tdown[i.x][i.y]
            s.tdown[i.x][i.y] = util.time()
            table.insert(s.list, i)
            if max and #s.list > max then rem = table.remove(s.list, 1) end
        else
            for j,w in ipairs(s.list) do
                if w.x == i.x and w.y == i.y then 
                    rem = table.remove(s.list, j)
                end
            end
            s.theld[i.x][i.y] = util.time() - s.tdown[i.x][i.y]
        end

        if add then s.held[add.x][add.y] = 1 end
        if rem then s.held[rem.x][rem.y] = 0 end
   
        if #s.held > min then return s.held, add, rem end
    end
}

_grid.momentary.input.muxfilter = _obj_:new {
    point = function(s, ...) return ... end,
    line = function(s, held, add, rem) 
        return held:new(), add, rem, s.theld, s.list --> return s.v:put(held) ?
    end,
    plane = function(s, held, ...) 
        return held:new(), add, rem, s.theld, s.list --> return s.v:put(held) ?
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

--init v, support edge, if edge == 0 support count, theld
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
