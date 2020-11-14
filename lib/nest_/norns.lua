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

            v = devs[kk].handler
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
                if v.dirty then 
                    v.dirty = false
                    v.redraw()
                end

                --v.animate(elapsed)
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

_screen.control = _control:new {
    output = _output:new()
}

----------------------------------------------------------------------------------------------------

_enc = _group:new()
_enc.devk = 'enc'

_enc.control = _control:new { 
    n = 2,
    input = _input:new()
}

_enc.control.input.filter = function(self, args) -- args = { n, d }
    if type(n) == "table" then 
        if tab.contains(self.n, args[1]) then return args
    elseif args[1] == self.n then return args
    else return nil
    end
end

_enc.muxcontrol = _enc.control:new()

_enc.muxcontrol.input.filter = function(self, args) -- args = { n, d }
    if type(n) == "table" then 
        if tab.contains(self.n, args[1]) then return { "line", args[1], args[2] }
    elseif args[1] == self.n then return { "point", args[1], args[2] }
    else return nil
    end
end

_enc.muxcontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_enc.muxcontrol.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

_enc.metacontrol = _metacontrol:new { 
    n = 2,
    input = _input:new()
}

_enc.metacontrol.input.filter = _enc.control.input.filter

_enc.muxmetacontrol = _enc.metacontrol:new()

_enc.muxmetacontrol.input.filter = _enc.muxcontrol.input.filter

_enc.muxmetacontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_enc.muxmetacontrol.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

--> _enc.number (like the param)

_enc.number = _enc.muxcontrol:new { --> control? (control becomes affordance)
    controlspec = nil,
    range = { 0, 1 },
    step = 0.01,
    units = '',
    quantum = 0.01,
    warp = 'lin'
    wrap = false
}

_enc.number.new = function(self, o)
    local cs = o.p_.controlspec

    o = _enc.muxcontrol.new(self, o)
    o.controlspec = cs

    if not o.controlspec then
        o.controlspec = controlspec:new(o.p_.range[1], o.p_.range[2], o.p_.warp, o.p_.step, o.v, o.p_.units, o.p_.quantum, o.p_.wrap)
    end

    return o
end

----------------------------------------------------------------------------------------------------

_key = _group:new()
_key.devk = 'key'

_key.control = _control:new { 
    n = 2,
    edge = 1,
    input = _input:new()
}

_key.control.input.filter = _enc.control.input.filter

_key.muxcontrol = _key.control:new()

_key.muxcontrol.input.filter = _enc.muxcontrol.input.filter

_key.muxcontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_key.muxcontrol.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

_key.metacontrol = _metacontrol:new { 
    n = 2,
    edge = 1,
    input = _input:new()
}

_key.metacontrol.input.filter = _key.control.input.filter

_key.muxmetacontrol = _key.metacontrol:new()

_key.muxmetacontrol.input.filter = _key.muxcontrol.input.filter

_key.muxmetacontrol.input.muxhandler = _obj_:new {
    point = { function(s, z) end },
    line = { function(s, v, z) end }
}

_key.muxmetacontrol.input.handler = function(s, k, ...)
    return s.muxhandler[k](s, ...)
end

_key.binary = _key.muxcontrol:new {
    fingers = nil
}

local function minit(n)
    if type(n) == 'table' then
        local ret = {}
        for i = 1, #n do ret[i] = 0 end
        return ret
    else return 0 end
end

_key.binary.new = function(self, o) 
    o = key.muxcontrol.new(self, o)

    rawset(o, 'list', {})

    local axis = o.n
    local v = minit(axis)
    o.held = minit(axis)
    o.tdown = minit(axis)
    o.tlast = minit(axis)
    o.theld = minit(axis)
    o.vinit = minit(axis)
    o.blank = {}

    o.arg_defaults = {
        minit(axis),
        minit(axis),
        nil,
        nil,
        o.list
    }

    if type(v) == 'table' and (type(o.v) ~= 'table' or (type(o.v) == 'table' and #o.v ~= #v)) then o.v = v end
    
    return o
end

_key.momentary = _key.binary:new()
