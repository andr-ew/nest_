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

local function fill(s, a, cb)
    local x2 = s.p_.x[1]
    local i = 0
    if s.p_.x[1] > s.p_.x[2] then
        x2 = 1
        for x = s.p_.x[1], 64 do
            i = i + 1

            local lvl = cb(i)
            if lvl > 0 then a:led(s.p_.n, x, lvl) end
        end
    end
    
    for x = x2, s.p_.x[2] do
        i = i + 1

        local lvl = cb(i)
        if lvl > 0 then a:led(s.p_.n, x, lvl) end
    end
end

local lvl = function(s, i)
    local x = s.p_.lvl
    return (type(x) ~= 'table') and ((i > 0) and x or 0) or x[i + 1] or 15
end

_arc.fill.output.redraw = function(s, a, v)
    if type(s.p_.x) == 'table' then
        local vmode = 1
        local vscale
        local range = s.p_.x[2] - s.p_.x[1] + 1
        
        if s.p_.x[1] > s.p_.x[2] then
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
            fill(s, a, function(i)
                local j = 0
                if vmode == 1 then
                    if i == vscale then j = 1 end
                elseif vmode == 2 then
                    if i >= vscale[1] and i <= vscale[2] then j = 1 end
                else
                    j = v[i]
                end 

                return lvl(s, j)
            end)
        end
    else
        local lvl = lvl(s, (type(v) == 'table') and v[1] or v)
        if lvl > 0 then a:led(s.p_.n, s.p_.x, lvl) end
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

    local v = value + (d * self.inc)

    if self.wrap then
        while v > self.range[2] do
            v = v - (self.range[2] - self.range[1])
        end
        while v < self.range[1] do
            v = v + (self.range[2] - self.range[1])
        end
    end

    local c = util.clamp(v,self.range[1],self.range[2])
    if value ~= c then
        return c
    end
end

_arc.number.output.redraw = function(s, a, v)
    local range = s.p_.x[2] - s.p_.x[1] + 1
    
    if s.p_.x[1] > s.p_.x[2] then
        range = 64 + range
    end
    
    if lvl(s, 0) == 0 then
        a:led(s.p_.n, math.floor(((v * range) + s.p_.x[1])) % 64, lvl(s, 1))
    else
        local _, remainder = math.modf(v / s.cycle)
        local mod

        if v == 0 then mod = 0
        elseif remainder == 0 then mod = s.cycle
        else mod = v % s.cycle end

        local scale = math.floor(mod * range) + 1
        fill(s, a, function(i)
            return lvl(s, i == scale and 1 or 0)
        end)
    end
end

_arc.key.affordance = _affordance:new { 
    n = 2,
    edge = 1,
    input = _input:new()
}

_arc.key.affordance.input.filter = _arc.delta.input.filter
