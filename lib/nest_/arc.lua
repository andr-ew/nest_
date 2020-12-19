_arc = _group:new()
_arc.devk = 'a'

_arc.key = _group:new()
_arc.key.devk = 'akey'

_arc.affordance = _affordance:new {
    v = 0,
    n = 1,
    x = 1,
    lvl = 15,
    aa = false,
    input = _input:new(),
    output = _output:new()
}

_arc.affordance.input.filter = function(s, args)
    if args[1] == s.n then return args end
end

_arc.key.affordance = _affordance:new { 
    n = 2,
    edge = 1,
    input = _input:new()
}

_arc.key.affordance.input.filter = _arc.affordance.input.filter

_arc.fill = _arc.affordance:new { v = { 0, 1 } , x = { 34, 33 } }

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
