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

-- update -> filter -> handler -> muxhandler -> action -> v

_grid.muxcontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end },
    plane = { function(s, x, y, z) end }
}

_grid.muxcontrol.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
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

_grid.muxcontrol.output.muxredraw = _obj_:new {
    point = function(s) end,
    line_x = function(s) end,
    line_y = function(s) end,
    plane = function(s) end
}

_grid.muxcontrol.output.redraw = function(s, g, v)
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
        s.muxredraw.point(s, g, v)
    elseif has_axis.x and has_axis.y then
        s.muxredraw.plane(s, g, v)
    else
        if has_axis.x then
            s.muxredraw.line_x(s, g, v)
        elseif has_axis.y then
            s.muxredraw.line_y(s, g, v)
        end
    end
end

_grid.muxmetacntrl = _grid.metacontrol:new {
    input = _grid.muxcontrol.input:new(),
    output = _grid.muxcontrol.output:new()
}

_grid.momentary = _grid.muxcontrol:new({ count = nil, held = 0, tdown = 0, tlast = 0, theld = 0, list = 0, vinit = 0 })

_grid.momentary.new = function(self, o) 
    o = _grid.muxcontrol.new(self, o)

    rawset(o, 'list', {})

    local _, axis = input_contained(o, { -1, -1 })

    -- why am I dumb ........
    if axis.x and axis.y then 
        v = {}
        o.held = {}
        o.vinit = {}
        o.tdown = {}
        o.tlast = {}
        o.theld = {}
        for x = 1, axis.x do 
            v[x] = {}
            o.held[x] = {}
            o.vinit[x] = {}
            o.tdown[x] = {}
            o.tlast[x] = {}
            o.theld[x] = {}
            for y = 1, axis.y do
                v[x][y] = 0
                o.held[x][y] = 0
                o.vinit[x][y] = 0
                o.tdown[x][y] = 0
                o.tlast[x][y] = 0
                o.theld[x][y] = 0
            end
        end
    elseif axis.x or axis.y then
        v = {}
        o.held = {}
        o.vinit = {}
        o.tdown = {}
        o.tlast = {}
        o.theld = {}
        for x = 1, (axis.x or axis.y) do 
            v[x] = 0
            o.held[x] = 0
            o.vinit[x] = 0
            o.tdown[x] = 0
            o.tlast[x] = 0
            o.ntheld[x] = 0
        end
    else 
        v = 0
    end

    if type(o.v) ~= type(v) or #o.v ~= #v then o.v = v end
    
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
    point = function(s, x, y, z)
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
   
        return #s.list > min and s.held or s.vinit, add, rem, s.theld, s.list
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
            rem = i
            for j,w in ipairs(s.list) do
                if w.x == i.x and w.y == i.y then 
                    rem = table.remove(s.list, j)
                end
            end
            s.theld[i.x][i.y] = util.time() - s.tdown[i.x][i.y]
        end

        if add then s.held[add.x][add.y] = 1 end
        if rem then s.held[rem.x][rem.y] = 0 end

        return #s.list > min and s.held or s.vinit, add, rem, s.theld, s.list
    end
}

local lvl = function(s, i)
    local x = s.p_.lvl
    -- come back later and understand or not understand ? :)
    return (type(x) ~= 'table') and ((i > 0) and x or 0) or x[i + 1] or 15
end

_grid.momentary.output.muxredraw = _obj_:new {
    point = function(s, g, v)
        g:led(s.p_.x, s.p_.y, lvl(s, v * 2 + 1))
    end,
    line_x = function(s, g, v)
        for x,l in ipairs(v) do g:led(x + s.p_.x[1] - 1, s.p_.y, lvl(s, l)) end
    end,
    line_y = function(s, g, v)
        for y,l in ipairs(v) do g:led(s.p_.x, y + s.p_.y[1] - 1, lvl(s, l)) end
    end,
    plane = function(s, g, v)
        for x,r in ipairs(v) do 
            for y,l in ipairs(r) do g:led(x + s.p_.x[1] - 1, y + s.p_.y[1] - 1, lvl(s, l)) end
        end
    end
}

_grid.fill = _grid.muxcontrol:new()
_grid.fill.input = nil

_grid.fill.new = function(self, o) 
    o = _grid.muxcontrol.new(self, o)

    local _, axis = input_contained(o, { -1, -1 })
    local v

    if axis.x and axis.y then 
        v = {}
        for x = 1, axis.x do 
            v[x] = {}
            for y = 1, axis.y do
                v[x][y] = 1
            end
        end
    elseif axis.x or axis.y then
        v = {}
        for x = 1, (axis.x or axis.y) do 
            v[x] = 1
        end
    else 
        v = 1
    end

    if type(o.v) ~= type(v) then o.v = v end

    return o
end

_grid.fill.output.muxredraw = _obj_:new {
    point = _grid.momentary.output.muxredraw.point,
    line_x = _grid.momentary.output.muxredraw.line_x,
    line_y = _grid.momentary.output.muxredraw.line_y,
    plane = _grid.momentary.output.muxredraw.plane
}

--init v, support edge, if edge == 0 support count, theld
_grid.value = _grid.muxcontrol:new()
_grid.value.input.muxhandler = _obj_:new {
    point = function(s, x, y, z) 
        if z > 0 then return 0 end
    end,
    line = function(s, x, y, z) 
        if z > 0 then
            return x - s.p_.x[1]
        end
    end,
    plane = function(s, x, y, z) 
        if z > 0 then
            return { x = x - s.p_.x[1], y = y - s.p_.y[1] }
        end
    end
}
_grid.value.output.muxredraw = _obj_:new {
    point = function(s, g, v)
        g:led(s.p_.x, s.p_.y, lvl(s, 1))
    end,
    line_x = function(s, g, v)
        for i = s.p_.x[1], s.p_.x[2] do
            g:led(i, s.p_.y, lvl(s, (s.v == i - s.p_.x[1]) and 1 or 0))
        end
    end,
    line_y = function(s, g, v)
        for i = s.p_.y[1], s.p_.y[2] do
            g:led(s.p_.x, i, lvl(s, (s.v == i - s.p_.y[1]) and 1 or 0))
        end
    end,
    plane = function(s, g, v)
        for i = s.x[1], s.x[2] do
            for j = s.p_.y[1], s.p_.y[2] do
                g:led(i, j, lvl(s, ((s.v.x == i - s.p_.x[1]) and (s.v.y == j - s.p_.y[1])) and 1 or 0))
            end
        end
    end
}

return _grid
