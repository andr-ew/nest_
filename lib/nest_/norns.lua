tab = require 'tabutil'

nest_.connect = function(self, objects, fps)
    self:do_init()

    local devs = {}

    local fps = fps or 30
    local elapsed = 0

    -- elapsed // 3 % 2

    for k,v in pairs(objects) do
        if k == 'g' or k == 'a' then
            local kk = k
            local vv = v
            
            devs[kk] = _dev:new {
                object = vv,
                redraw = function() 
                    vv:all(0)
                    self:draw(kk, elapsed) 
                    vv:refresh()
                end,
                handler = function(...)
                    self:update(kk, {...}, {})
                end
            }

            v[(kk == 'g') and 'key' or 'delta'] = devs[kk].handler
        elseif k == 'm' or k == 'h' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                object = vv,
                handler = function(data)
                    self:update(kk, data, {})
                end
            }

            v.event = devs[kk].handler
        elseif k == 'enc' or k == 'key' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                handler = function(...)
                    self:update(kk, {...}, {})
                end
            }

            _G[kk] = devs[kk].handler
        elseif k == 'screen' then
            devs[kk] = _dev:new {
                object = screen,
                redraw = function()
                    screen.clear()
                    self:draw('screen', elapsed)
                    screen.update()
                end
            }
            
            redraw = devs[kk].redraw
        else 
            print('nest_.connect: invalid device key. valid options are g, a, m, h, screen, enc, key')
        end
    end

    clock.run(function() 
        while true do 
            clock.sleep(1/fps)
            elapsed = elapsed + 1/fps
            
            for k,v in pairs(devs) do 
                if v.redraw and v.dirty then 
                    v.dirty = false
                    v.redraw()
                end
            end
        end   
    end)

    local function linkdevs(obj) 
        if type(obj) == 'table' and obj.is_obj then
            rawset(obj._, 'devs', devs)
            
            --might not be needed with _output.redraw args
            for k,v in pairs(objects) do 
                rawset(obj._, k, v)
            end
            
            for k,v in pairs(obj) do 
                linkdevs(v)
            end
        end
    end

    linkdevs(self)
    
    return self
end

----------------------------------------------------------------------------------------------------

_screen = _group:new()
_screen.devk = 'screen'

_screen.affordance = _affordance:new {
    output = _output:new()
}

----------------------------------------------------------------------------------------------------

_enc = _group:new()
_enc.devk = 'enc'

_enc.affordance = _affordance:new { 
    n = 2,
    input = _input:new()
}

_enc.affordance.input.filter = function(self, args) -- args = { n, d }
    if type(n) == "table" then 
        if tab.contains(self.p_.n, args[1]) then return args end
    elseif args[1] == self.p_.n then return args
    else return nil
    end
end

_enc.muxaffordance = _enc.affordance:new()

_enc.muxaffordance.input.filter = function(self, args) -- args = { n, d }
    if type(self.p_.n) == "table" then 
        if tab.contains(self.p_.n, args[1]) then return { "line", args[1], args[2] } end
    elseif args[1] == self.p_.n then return { "point", args[1], args[2] }
    else return nil
    end
end

_enc.muxaffordance.input.muxhandler = _obj_:new {
    point = function(s, z) end,
    line = function(s, v, z) end
}

_enc.muxaffordance.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

_enc.metaaffordance = _metaaffordance:new { 
    n = 2,
    input = _input:new()
}

_enc.metaaffordance.input.filter = _enc.affordance.input.filter

_enc.muxmetaaffordance = _enc.metaaffordance:new()

_enc.muxmetaaffordance.input.filter = _enc.muxaffordance.input.filter

_enc.muxmetaaffordance.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_enc.muxmetaaffordance.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

local function minit(n)
    if type(n) == 'table' then
        local ret = {}
        for i = 1, #n do ret[i] = 0 end
        return ret
    else return 0 end
end

local function delta_number(self, value, d)
    local v = value + d

    if self.wrap then
        while v > self.range[2] do
            v = v - (self.range[2] - self.range[1]) - 1
        end
        while v < self.range[1] do
            v = v + (self.range[2] - self.range[1]) + 1
        end
    end

    local c = util.clamp(v,self.range[1],self.range[2])
    if value ~= c then
        return c
    end
end

_enc.number = _enc.muxaffordance:new {
    range = { 0, 1 },
    wrap = false
}

_enc.number.new = function(self, o)
    o = _enc.muxaffordance.new(self, o)

    local v = minit(o.p_.n)
    if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end

    return o
end

_enc.number.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        return delta_number(s, s.v, d), d
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        local v = delta_number(s, s.v[i], d)
        if v then
            local del = minit(s.p_.n)
            del[i] = d
            s.v[i] = v
            return s.v, del
        end
    end
}

local function delta_control(self, v, d)
    local value = self.controlspec:unmap(v) + (d * self.controlspec.quantum)

    if self.controlspec.wrap then
        while value > 1 do
            value = value - 1
        end
        while value < 0 do
            value = value + 1
        end
    end
    
    local c = self.controlspec:map(util.clamp(value, 0, 1))
    if v ~= c then
        return c
    end
end

_enc.control = _enc.muxaffordance:new {
    controlspec = nil,
    range = { 0, 1 },
    step = 0.01,
    units = '',
    quantum = 0.01,
    warp = 'lin',
    wrap = false
}

_enc.control.new = function(self, o)
    local cs = o.controlspec

    o = _enc.muxaffordance.new(self, o)

    o.controlspec = cs or controlspec.new(o.p_.range[1], o.p_.range[2], o.p_.warp, o.p_.step, o.v, o.p_.units, o.p_.quantum, o.p_.wrap)

    local v = minit(o.p_.n)
    if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end

    return o
end

_enc.control.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        local last = s.v
        return delta_control(s, s.v, d), s.v - last 
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        local v = delta_control(s, s.v[i], d)
        if v then
            local last = s.v[i]
            local del = minit(s.p_.n)
            s.v[i] = v
            del[i] = v - last
            return s.v, del
        end
    end
}

local tab = require 'tabutil'

local function delta_option_point(self, value, d)
    local i = tab.key(self.p_.options, value) or 0
    local v = i + d

    if self.wrap then
        while v > #self.p_.options do
            v = v - #self.options
        end
        while v < 1 do
            v = v + #self.p_.options + 1
        end
    end

    local c = util.clamp(v, 1, #self.p_.options)
    if i ~= c then
        return self.p_.options[c]
    end
end

local function delta_option_line(self, value, dx, dy)
    local i = 0
    local j = 0

    for x, w in ipairs(self.p_.options) do
        for y, z in ipairs(w) do
            if z == value then
                i = x
                j = y
            end
        end
    end

    vx = i + (dx or 0)
    vy = j + (dy or 0)

    if self.wrap then
        while vx > #self.p_.options do
            vx = vx - #self.options
        end
        while vx < 1 do
            vx = vx + #self.p_.options + 1
        end
    end

    local cx = util.clamp(vx, 1, #self.p_.options)

    if self.wrap then
        while vy > #self.p_.options[cx] do
            vy = vy - #self.options[cx]
        end
        while vy < 1 do
            vy = vy + #self.p_.options[cx] + 1
        end
    end

    local cy = util.clamp(vy, 1, #self.p_.options[cx])

    if i ~= cx or j ~= cy then
        return self.p_.options[cx][cy]
    end
end

_enc.option = _enc.muxaffordance:new {
    value = "",
    options = {},
    wrap = false
}

_enc.option.new = function(self, o) 
    o = _enc.muxaffordance.new(self, o)

    if type(o.p_.n) == 'table' then
        local contains = false

        for x, w in ipairs(self.p_.options) do
            for y, z in ipairs(w) do
                if z == o.v then
                    contains = true
                end
            end
        end

        if not contains then o.v = o.p_.options[1][1] or "" end
    else
        if not tab.contains(o.p_.options, o.v) then o.v = o.p_.options[1] or "" end
    end

    return o
end

_enc.option.input.muxhandler = _obj_:new {
    point = function(s, n, d) 
        return delta_option_point(s, s.v, d), d
    end,
    line = function(s, n, d) 
        local i = tab.key(s.p_.n, n)
        local dd = { 0, 0 }
        dd[i] = d
        local v = delta_option_line(s, s.v, dd[2], dd[1])
        if v then
            local del = minit(s.p_.n)
            del[i] = d
            return v, del
        end
    end
}

----------------------------------------------------------------------------------------------------

_key = _group:new()
_key.devk = 'key'

_key.affordance = _affordance:new { 
    n = 2,
    edge = 1,
    input = _input:new()
}

_key.affordance.input.filter = _enc.affordance.input.filter

_key.muxaffordance = _key.affordance:new()

_key.muxaffordance.input.filter = _enc.muxaffordance.input.filter

_key.muxaffordance.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_key.muxaffordance.input.handler = _enc.muxaffordance.input.handler

_key.metaaffordance = _metaaffordance:new { 
    n = 2,
    edge = 1,
    input = _input:new()
}

_key.metaaffordance.input.filter = _key.affordance.input.filter

_key.muxmetaaffordance = _key.metaaffordance:new()

_key.muxmetaaffordance.input.filter = _key.muxaffordance.input.filter

_key.muxmetaaffordance.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_key.muxmetaaffordance.input.handler = _enc.muxmetaaffordance.input.handler

_key.binary = _key.muxaffordance:new {
    fingers = nil
}

_key.binary.new = function(self, o) 
    o = _key.muxaffordance.new(self, o)

    rawset(o, 'list', {})

    local axis = o.p_.n
    local v = minit(axis)
    o.held = minit(axis)
    o.tdown = minit(axis)
    o.tlast = minit(axis)
    o.theld = minit(axis)
    o.vinit = minit(axis)
    o.blank = {}

    o.arg_defaults =  {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.list
    }

    if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end
    
    return o
end

_key.binary.input.muxhandler = _obj_:new {
    point = function(s, n, z, min, max, wrap)
        if z > 0 then 
            s.tlast = s.tdown
            s.tdown = util.time()
        else s.theld = util.time() - s.tdown end
        return z, s.theld
    end,
    line = function(s, n, z, min, max, wrap)
        local i = tab.key(s.p_.n, n)
        local add
        local rem

        if z > 0 then
            add = i
            s.tlast[i] = s.tdown[i]
            s.tdown[i] = util.time()
            table.insert(s.list, i)
            if wrap and #s.list > wrap then rem = table.remove(s.list, 1) end
        else
            local k = tab.key(s.list, i)
            if k then
                rem = table.remove(s.list, k)
            end
            s.theld[i] = util.time() - s.tdown[i]
        end
        
        if add then s.held[add] = 1 end
        if rem then s.held[rem] = 0 end

        return (#s.list >= min and (max == nil or #s.list <= max)) and s.held or nil, s.theld, nil, add, rem, s.list
    end
}

_key.momentary = _key.binary:new()

local function count(s) 
    local min = 0
    local max = nil

    if type(s.p_.count) == "table" then 
        max = s.p_.count[#s.p_.count]
        min = #s.p_.count > 1 and s.p_.count[1] or 0
    else max = s.p_.count end

    return min, max
end

local function fingers(s)
    local min = 0
    local max = nil

    if type(s.p_.fingers) == "table" then 
        max = s.p_.fingers[#s.p_.fingers]
        min = #s.p_.fingers > 1 and s.p_.fingers[1] or 0
    else max = s.p_.fingers end

    return min, max
end

_key.momentary.input.muxhandler = _obj_:new {
    point = function(s, n, z)
        return _key.binary.input.muxhandler.point(s, n, z)
    end,
    line = function(s, n, z)
        local max
        local min, wrap = count(s)
        if s.fingers then
            min, max = fingers(s)
        end        

        local v,t,last,add,rem,list = _key.binary.input.muxhandler.line(s, n, z, min, max, wrap)
        if v then
            return v,t,last,add,rem,list
        else
            return s.vinit, s.vinit, nil, nil, nil, s.blank
        end
    end
}

_key.toggle = _key.binary:new { edge = 1, lvl = { 0, 15 } } -- it is wierd that lvl is being used w/o an output :/

_key.toggle.new = function(self, o) 
    o = _key.binary.new(self, o)

    rawset(o, 'toglist', {})

    local axis = o.p_.n

    --o.tog = minit(axis)
    o.ttog = minit(axis)

    o.arg_defaults = {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.toglist
    }

    return o
end

local function toggle(s, v)
    return (v + 1) % (((type(s.p_.lvl) == 'table') and #s.p_.lvl > 1) and (#s.p_.lvl) or 2)
end

_key.toggle.input.muxhandler = _obj_:new {
    point = function(s, n, z)
        local held = _key.binary.input.muxhandler.point(s, n, z)

        if s.p_.edge == held then
            return toggle(s, s.v), util.time() - s.tlast, s.theld
        end
    end,
    line = function(s, n, z)
        local held, theld, _, hadd, hrem, hlist = _key.binary.input.muxhandler.line(s, n, z, 0, nil)
        local min, max = count(s)
        local i
        local add
        local rem
       
        if s.edge == 1 and hadd then i = hadd end
        if s.edge == 0 and hrem then i = hrem end
 
        if i then   
            if #s.toglist >= min then
                local v = toggle(s, s.v[i])
                
                if v > 0 then
                    add = i
                    
                    if v == 1 then table.insert(s.toglist, i) end
                    if max and #s.toglist > max then rem = table.remove(s.toglist, 1) end
                else 
                    local k = tab.key(s.toglist, i)
                    if k then
                        rem = table.remove(s.toglist, k)
                    end
                end
            
                s.ttog[i] = util.time() - s.tlast[i]

                if add then s.v[add] = v end
                if rem then s.v[rem] = 0 end

            elseif #hlist >= min then
                for j,w in ipairs(hlist) do
                    s.toglist[j] = w
                    s.v[w] = 1
                end
            end
            
            if #s.toglist < min then
                for j,w in ipairs(s.v) do s.v[j] = 0 end
                s.toglist = {}
            end

            return s.v, s.ttog, theld, add, rem, s.toglist
        end
    end
}

_key.trigger = _key.binary:new { edge = 1, blinktime = 0.1 }

_key.trigger.new = function(self, o) 
    o = _key.binary.new(self, o)

    rawset(o, 'triglist', {})

    local axis = o.p_.n
    o.tdelta = minit(axis)

    o.arg_defaults = {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.triglist
    }
    
    return o
end

_key.trigger.input.muxhandler = _obj_:new {
    point = function(s, n, z)
        local held = _key.binary.input.muxhandler.point(s, n, z)
        
        if s.edge == held then
            return 1, s.theld, util.time() - s.tlast
        end
    end,
    line = function(s, n, z)
        local max
        local min, wrap = count(s)
        if s.fingers then
            min, max = fingers(s)
        end        
        local held, theld, _, hadd, hrem, hlist = _key.binary.input.muxhandler.line(s, n, z, 0, nil)
        local ret = false
        local lret

        if s.edge == 1 and #hlist > min and (max == nil or #hlist <= max) and hadd then
            s.v[hadd] = 1
            s.tdelta[hadd] = util.time() - s.tlast[hadd]

            ret = true
            lret = hlist
        elseif s.edge == 1 and #hlist == min and hadd then
            for i,w in ipairs(hlist) do 
                s.v[w] = 1

                s.tdelta[w] = util.time() - s.tlast[w]
            end

            ret = true
            lret = hlist
        elseif s.edge == 0 and #hlist >= min - 1 and (max == nil or #hlist <= max - 1)and hrem and not hadd then
            s.triglist = {}

            for i,w in ipairs(hlist) do 
                if s.v[w] <= 0 then
                    s.v[w] = 1
                    s.tdelta[w] = util.time() - s.tlast[w]
                    table.insert(s.triglist, w)
                end
            end
            
            if s.v[hrem] <= 0 then
                ret = true
                lret = s.triglist
                s.v[hrem] = 1 
                s.tdelta[hrem] = util.time() - s.tlast[hrem]
                table.insert(s.triglist, hrem)
            end
        end
            
        if ret then return s.v, s.tdelta, s.theld, nil, nil, lret end
    end
}
