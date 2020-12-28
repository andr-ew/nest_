_arc = _group:new()
_arc.devk = 'a'

_arc.key = _group:new()
_arc.key.devk = 'akey'

_arc.delta = _affordance:new { n = 1, input = _input:new() }

_arc.delta.input.filter = function(s, args)
    if args[1] == s.p_.n then return args end
end

_arc.delta.input.handler = function(s, n, d)
    return d
end

_arc.fill = _affordance:new {
    v = 0,
    n = 1,
    x = { 33, 32 },
    lvl = 15,
    aa = false,
    output = _output:new()
}

local function xxx(s)
    local x = s.p_.x
    x = (type(x) == 'table') and x or { x, (x + 63 % 64) }
    x[1] = x[1] == 0 and 64 or x[1]
    x[2] = x[2] == 0 and 64 or x[2]
    return x
end

local function fill(s, a, x, cb)
    local x2 = x[1]
    local i = 0
    local n = s.p_.n
    if x[1] > x[2] then
        x2 = 1
        for y = x[1], 64 do
            i = i + 1

            local lvl = cb(i)
            if lvl > 0 then a:led(n, y, lvl) end
        end
    end
    
    for y = x2, x[2] do
        i = i + 1

        local lvl = cb(i)
        if lvl > 0 then a:led(n, y, lvl) end
    end
end

local lvl = function(s, i)
    local x = s.p_.lvl
    return (type(x) ~= 'table') and ((i > 0) and x or 0) or x[i + 1] or 15
end

_arc.fill.output.redraw = function(s, a, v)
    local vmode = 1
    local vscale
    local x = xxx(s)
    local range = x[2] - x[1] + 1
    
    if x[1] > x[2] then
        range = 64 + range
    end

    if type(v) == 'table' then
        vmode = 3
        if #v == 2 then
            vmode = 2
            vscale = { math.floor(v[1] * range), math.ceil(v[2] * range) }
        end
    else
        vscale = math.floor(v * range)
    end

    if s.aa and vmode <3 then
        if vmode == 1 then vscale = { vscale, vscale } end

        a:segment(s.p_.n, (vscale[1] / 64) * 2 * math.pi, (vscale[2] / 64) * 2 * math.pi, lvl(s, 1))
    else
        fill(s, a, x, function(i)
            local j = 0
            if vmode == 1 then
                if i == vscale then j = lvl(s, 1) end
            elseif vmode == 2 then
                if i >= vscale[1] and i <= vscale[2] then j = lvl(s, 1) end
            else
                j = v[i] or 0
            end 

            return j
        end)
    end
end

_arc.affordance = _arc.fill:new {
    v = 0,
    range = { 0, 1 },
    sens = 1,
    wrap = false,
    input = _input:new()
}

_arc.affordance.input.filter = function(s, args)
    if args[1] == s.p_.n then
        return { args[1], args[2] * s.p_.sens }
    end
end

_arc.number = _arc.affordance:new {
    cycle = 1.0,
    inc = 1/64,
    indicator = 1
}

_arc.number.input.handler = function(self, n, d)
    local value = self.value
    local range = self.p_.range

    local v = value + (d * self.inc)

    if self.p_.wrap then
        while v > range[2] do
            v = v - (range[2] - range[1])
        end
        while v < range[1] do
            v = v + (range[2] - range[1])
        end
    end

    local c = util.clamp(v, range[1], range[2])
    if value ~= c then
        return c
    end
end

_arc.number.output.redraw = function(s, a, v)
    local x = xxx(s)
    local range = x[2] - x[1] + 1
    
    if x[1] > x[2] then
        range = 64 + range
    end
    
    if lvl(s, 0) == 0 then
        a:led(s.p_.n, math.floor(((v/s.cycle * range) + x[1])) % 64, lvl(s, 1))
    else
        local _, remainder = math.modf(v / s.cycle)
        local mod

        if v == 0 then mod = 0
        elseif remainder == 0 then mod = s.cycle
        else mod = v % s.cycle end

        local scale = math.floor(mod * range) + 1
        fill(s, a, x, function(i)
            return lvl(s, i == scale and 1 or 0)
        end)
    end
end

_arc.control = _arc.affordance:new {
    x = { 42, 24 },
    lvl = { 0, 4, 15 },
    controlspec = nil,
    range = { 0, 1 },
    step = 0, --0.01,
    units = '',
    quantum = 0.01,
    warp = 'lin',
    wrap = false
}

_arc.control.copy = function(self, o)
    local cs = o.controlspec

    o = _arc.affordance.copy(self, o)

    o.controlspec = cs or controlspec.new(o.p_.range[1], o.p_.range[2], o.p_.warp, o.p_.step, o.v, o.p_.units, o.p_.quantum, o.p_.wrap)

    return o
end

_arc.control.input.handler = function(self, n, d)
    local value = self.controlspec:unmap(self.v) + (d * self.controlspec.quantum)

    if self.p_.controlspec.wrap then
        while value > 1 do
            value = value - 1
        end
        while value < 0 do
            value = value + 1
        end
    end
    
    local c = self.p_.controlspec:map(util.clamp(value, 0, 1))
    if self.v ~= c then
        return c
    end
end

_arc.control.output.redraw = function(s, a, v)
    local x = xxx(s)
    local range = x[2] - x[1]
    
    if x[1] > x[2] then
        range = 64 + range
    end
    
    local scale = math.floor(s.controlspec:unmap(v) * range)

    if s.aa then
        a:segment(s.p_.n, (x[1] / 64) * 2 * math.pi, ((x[1] + scale) / 64) * 2 * math.pi, lvl(s, 1))
    else
        fill(s, a, x, function(i)
            local l = 0
            local m = util.linlin(1, range, s.p_.controlspec.minval, s.p_.controlspec.maxval, i)
            local v = scale + 1
            if i == v then l = 2
            elseif i > v and m <= 0 then l = 1
            elseif i < v and m >= 0 then l = 1 end
            return lvl(s, l)
        end)
    end
end

_arc.option = _arc.affordance:new {
    v = 1, -- { 1, 3 }
    options = 4,
    size = nil, -- 10, { 10, 10 20, 10 }
    include = nil,
    glyph = nil,
    range = function(s) return { 1, s.options } end, -- { 1, 3 }, { 1, 2, 4 }
    margin = 0
}

_arc.option.input.handler = function(self, n, d)
    local v = self.value + d
    local range = { self.p_.range[1], self.p_.range[2] + 1 - self.p_.sens }
    local include = self.p_.include

    if self.p_.wrap then
        while v > range[2] do
            v = v - (range[2] - range[1])
        end
        while v < range[1] do
            v = v + (range[2] - range[1])
        end
    end

    if include then
        local i = 0
        while not tab.contains(include, math.floor(v)) do
            v = v + ((d > 0) and 1 or -1)
            i = i + 1
            if i > 64 then break end -- seat belt
        end
    end

    local c = util.clamp(v,range[1],range[2])
    if self.value ~= c then
        return c, math.floor(c)
    end
end

_arc.option.output.redraw = function(s, a, v)
    local x = xxx(s)
    local count = x[2] - x[1]
    
    if x[1] > x[2] then
        count = 64 + count
    end
    
    local options = s.p_.options
    local n = s.p_.n
    local vr = math.floor(v)

    if s.glyph then
        local gl = s.p_('glyph', vr, count)

        for j, w in ipairs(gl) do
            a:led(n, math.floor(j + x[1]) % 64, w)
        end
    else
        local margin = s.p_.margin
        local stab = type(s.p_.size) == 'table'
        local size = s.p_.size or (count/options - s.p_.margin)
        local range = s.p_.range
        local include = s.p_.include
        local lvl = type(s.p_.lvl) == 'table' and s.p_.lvl or { s.p_.lvl }
        while #lvl < 3 do table.insert(lvl, 1, 0) end

        local st = 0
        for i = 1, options do
            local sel = vr == i
            local inrange = i >= range[1] and i <= range[2]
            local isinclude = true
            if include and not tab.contains(include, i) then isinclude = false end
            local l = 1 + (sel and 1 or 0) + ((inrange and isinclude) and 1 or 0)
            local sz = (stab and size[i] or size)

            if lvl[l] > 0 then
                for j = st, st + sz - 1 do
                    a:led(n, math.floor(j + x[1]) % 64, lvl[l])
                end
            end
            
            st = st + sz + margin
        end
    end
end

_arc.key.affordance = _affordance:new { 
    n = 2,
    edge = 1,
    tdown = 0,
    input = _input:new()
}

_arc.key.affordance.input.filter = _arc.delta.input.filter

_arc.key.momentary = _arc.key.affordance:new()
_arc.key.momentary.input.handler = function(s, n, z)
    local theld
    if z > 0 then 
        s.tdown = util.time()
    else theld = util.time() - s.tdown end
    return z, theld
end

_arc.key.trigger = _arc.key.affordance:new()
_arc.key.trigger.input.handler = function(s, n, z)
    local theld
    if z > 0 then 
        s.tdown = util.time()
    else theld = util.time() - s.tdown end

    if z == s.p_.edge then return 1, theld end
end

_arc.key.toggle = _arc.key.affordance:new()
_arc.key.toggle.input.handler = function(s, n, z)
    local theld
    if z > 0 then 
        s.tdown = util.time()
    else theld = util.time() - s.tdown end

    if z == s.p_.edge then return ~ s.v & 1, theld end
end
