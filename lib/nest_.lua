_input = {}
function _input:new(o)
    local _ = {
        is_input = true,
        control = nil,
--        transform = function(v) return v end,
--        handler = function(self, ...) return false end,
        update = function(self, deviceidx, args)
            if(self._.deviceidx == deviceidx) then
                return args
            else return nil end
        end
    }

    o = o or {}

    if o._ ~= nil then
        setmetatable(o._, _)
        o._.__index = _
    end

    setmetatable(o, {
        __index = function(t, k)
            if k == "_" then return _
            elseif self[k] ~= nil then return self[k]
            elseif _[k] ~= nil then return _[k]
            elseif _.control and _.control[k] ~= nil then return _.control[k]
            else return nil end
        end,
        __newindex = function(t,k,v)
            if _[k] ~= nil then rawset(_,k,v) 
            elseif _.control and _.control[k] ~= nil then rawset(_.control,k,v) 
            else rawset(t,k,v) end
        end
    })

    return o
end

_output = {}
function _output:new(o)
    local _ = {
        is_output = true,
        control = nil,
--        transform = function(v) return v end,
--        redraw = function(self) end,
        throw = function(self, ...)
            self._.control._.throw(self._.control, self.deviceidx, ...)
        end,
        draw = function(self, deviceidx)
            if(self._.deviceidx == deviceidx) then
                return {}
            else return nil end
        end
    }

    o = o or {}

    if o._ ~= nil then
        setmetatable(o._, _)
        o._.__index = _
    end

    setmetatable(o, {
        __index = function(t, k)
            if k == "_" then return _
            elseif self[k] ~= nil then return self[k]
            elseif _[k] ~= nil then return _[k]
            elseif _.control and _.control[k] ~= nil then return _.control[k]
            else return nil end
        end,
        __newindex = function(t,k,v)
            if _[k] ~= nil then rawset(_,k,v) 
            elseif _.control and _.control[k] ~= nil then rawset(_.control,k,v) 
            else rawset(t,k,v) end
        end
    })
    
    return o
end

_control = {
    v = 0,
    a = function(s, v) end,
    order = 0,
    en = true,
    init = function(s) end,
    inputs = {},
    outputs = {},
    help = function(s) end
}

function _control:new(o)
    local _ = {
        --[[

        big change: these secret members should really only exist for nest_ & _group (for clean indexing, the only places that matters), otherwise it messes up the object oriented behavior for inputs, outputs, controls. also, remove the underscores for these classes, that helps illustrate the difference !

        ]]
        is_control = true,
        k = nil,
        p = nil,
        deviceidx = nil, --- store the group here instead, that seems cleaner. deviceidx is for input/output (we need to kind of steer clear of duplicate keys because of the upward indexing stuff with the secret table removed)
        do_init = function(self)
            self:init()
        end,
        update = function(self, deviceidx, args)
            local d = false

            for i,v in ipairs(self.inputs) do
                local hargs = v:update(deviceidx, args)

                if hargs ~= nil then
                    d = true

                    if self.metacontrols_disabled then
                        for i,w in ipairs(self.metacontrols) do
                            w:pass(v.handler, hargs)
                        end
                    end

                    if v.handler then v:handler(table.unpack(hargs)) end
                end
            end

            if d then for i,v in ipairs(self.outputs) do
                self.device_redraws[deviceidx]()
            end end
        end,
        draw = function(self, deviceidx)
            for i,v in ipairs(self.outputs) do
                local rdargs = v:draw(deviceidx)
                if rdargs ~= nil and v.redraw then v:redraw(table.unpack(rdargs)) end
            end
        end,
        throw = function(self, deviceidx, method, ...)
            if self.catch and self.deviceidx == deviceidx then
                self:catch(deviceidx, method, ...)
            else self.p:throw(deviceidx, method, ...) end
        end,
        print = function(self) end,
        get = function(self) return self.v end,
        set = function(self, v, silent)
            self.v = v
            silent = silent or false

            if not silent then
                self:a(v, self.meta)

                if d then for i,v in ipairs(self.outputs) do
                    self.device_redraws[deviceidx]()
                end end
            end
        end,

        --[[
        
        add param = nil
        add :link(param.id)
            set param to param
            set v to param.v
            set get & set to param .get & .set
            overwrite param.a to update self, run self.a
        end

        ]]

        write = function(self) end,
        read = function(self) end
    }

    o = o or {}

    --setmetatable(_, { __index = self._ }) ----------- ?

    --[[
    if o._ ~= nil then
        setmetatable(o._, _)
        o._.__index = _
    end
    ]]

    o.inputs = o.inputs or {}
    o.outputs = o.outputs or {}

    for i,v in ipairs(self.inputs) do
        o.inputs[i] = o.inputs[i] or v:new()
    end
    for i,v in ipairs(self.outputs) do
        o.outputs[i] = o.inputs[i] or v:new()
    end
    for i,v in ipairs(o.inputs) do
        v._.control = o
        v._.deviceidx = v._.deviceidx or _.deviceidx
    end
    for i,v in ipairs(o.outputs) do
        v._.control = o
        v._.deviceidx = v._.deviceidx or _.deviceidx
    end

    setmetatable(o.inputs or self.inputs, {
        __newindex = function(t, k, v)
            if v.is_input then
                v._.control = t
                if v._.deviceidx == nil then v._.deviceidx  = _.deviceidx end
            end
            
            rawset(t,k,v)
        end
    })

    setmetatable(o.outputs or self.inputs, {
        __newindex = function(t, k, v)
            if v.is_output then
                v._.control = t
                if v._.deviceidx == nil then v._.deviceidx  = _.deviceidx end
            end

            rawset(t,k,v)
        end
    })

    local concat = function (n1, n2)
        for k, v in pairs(n2) do
            n1[k] = v
        end
        return n1
    end

    setmetatable(o, {
        __concat = concat,
        __tostring = function(t) end,
        __index = function(t, k)
            local findmeta = function(nest)
                if nest and nest.is_nest then
                    if nest._meta ~= nil and nest._meta[k] ~= nil then return nest._meta[k]
                    elseif nest._._meta ~= nil and nest._._meta[k] ~= nil then return nest._._meta[k]
                    elseif nest.p ~= nil then return findmeta(nest.p)
                    else return nil end
                end
            end

            -- rename nickname keys in o, maybe make a central table lookup
            if k == "_" then return _
            elseif k == "input" then return t.inputs[1]
            elseif k == "output" then return t.outputs[1]
            elseif k == "target" then return t.targets[1]
            elseif self[k] ~= nil then return self[k]
            elseif _[k] ~= nil then return _[k]
            elseif findmeta(_.p) ~= nil then return findmeta(_.p)
            else return nil end
        end,
        __newindex = function(t,k,v)
            if _[k] ~= nil then rawset(_,k,v) 
            else rawset(t,k,v) end
        end
    })

    return o
end

_metacontrol = {
    targets = {} 
}
function _metacontrol:new(o)
    o = _control:new(o)
    
    o._.is_metacontrol = true
    o._.pass = function(self, f, args) end
    --[[

    passing the function will work but not for recall

    ]]
    o._.metacontrols_disabled = true

    o.targets = self.targets or {}
    
    setmetatable(o.targets, {
        __newindex = function(t, k, v)
            local mt
            if v.is_nest then
                if v._._meta == nil then v._._meta = {} end
                if v._._meta.metacontrols == nil then v._._meta.metacontrols = {} end
                mt = v._._meta.metacontrols
            elseif v.is_control then 
                if v._.metacontrols == nil then v._.metacontrols = {} end
                mt = v.metacontrols
            end

            table.insert(mt, self)
            rawset(t,k,v)
        end
    })

    return o
end

nest_ = {}
function nest_:new(o)
    local _ = {
        do_init = function(self)
            self:init()
            table.sort(self, function(a,b) return a.order < b.order end)

            for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
        end,
        connect = function(self, devices)
            self:do_init()

            if self._._meta == nil then self._._meta = {} end
            local m = self._._meta

            m.devices = devices
            setmetatable(m, m.devices)
            m.devices.__index = m.devices

            m.device_redraws = {}

            for k,v in pairs(m.devices) do
                if k == 'g' or k == 'a' then
                    local kk = k
                    m.device_redraws[kk] = function() self:draw(kk) end
                    v[(kk == 'g') and 'key' or 'delta'] = function(...)
                        m[kk]:all(0)
                        self:update(kk, {...})
                        m.device_redraws[kk]()
                        m[kk]:refresh()
                    end
                elseif k == 'm' or k == 'h' then
                    local kk = k
                    v.event = function(data) self:update(kk, data) end
                elseif k == 'enc' then
                    v = function(...) self:update('enc', {...}) end
                elseif k == 'key' then
                    v = function(...) self:update('key', {...}) end
                elseif k == 'screen' then
                    m.device_redraws.screen = redraw
                    redraw = function()
                        screen.clear()
                        self:draw('screen')
                        screen.update()
                    end
                else print('nest_.connect: invalid device key. valid options are g, a, m, h, screen, enc, key')
                end
            end
            
            return self
        end,
        init = function(self) return self end,
        each = function(self, cb) return self end,
        is_nest = true,
        k = nil,
        p = nil,
        en = true,
        order = 0,
        update = function(self, deviceidx, args)
            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:update(deviceidx, args )
            end end
        end,
        draw = function(self, deviceidx)  
            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:draw(deviceidx)
            end end
        end,
        throw = function(self, deviceidx, method, ...)
            self.p:throw(deviceidx, method, ...)
        end,
        set = function(self, tv) end, --table set
        get = function(self) end,
        print = function(self) end,
        write = function(self) end,
        read = function(self) end
    }

    o = o or {}

    if o._ ~= nil then
        setmetatable(o._, _)
        o._.__index = _
    end

    local function nestify(p, k, v)
        if type(v) == "table" then
            if v.is_control then
            elseif v.is_nest then
            else
                v = nest_:new(v)
            end
            
            if v._ then
                rawset(v._, "k", k)
                rawset(v._, "p", p)
            end
        end
    end

    setmetatable(o, {
        __index = function(t, k)
            if k == "_" then return _
            elseif self[k] ~= nil then return self[k]
            elseif _[k] ~= nil then return _[k]
            else return nil end
        end,
        __newindex = function(t, k, v)
            if _[k] ~= nil then rawset(_,k,v) 
            else
                nestify(t, k, v)
                rawset(t,k,v)
            end
        end,
        __concat = concat,
        __tostring = function(t) end
    })

    local concat = function (n1, n2)
        for k, v in pairs(n2) do
            n1[k] = v
        end
        return n1
    end

    for k,v in pairs(o) do nestify(o, k, v) end

    return o
end


_group = {}
function _group:new(o)
    local _ = {
        k = nil,
        is_group = true,
        deviceidx = ""
    }

    o = o or {}

    if o._ ~= nil then
        setmetatable(o._, _)
        o._.__index = _
    end

    setmetatable(o, {
        __index = function(t, k)
            if k == "_" then return _
            elseif self[k] ~= nil then return self[k]
            elseif _[k] ~= nil then return _[k]
            else return nil end
        end,
        __newindex = function(t, k, v)
            if _[k] ~= nil then rawset(_,k,v) 
            else
                if type(v) == "table" and v.is_control then
                    v._.deviceidx = _.deviceidx 
                   
                    for i,w in ipairs(v.inputs) do
                        w._.deviceidx = w._.deviceidx or _.deviceidx
                    end
                    for i,w in ipairs(v.outputs) do
                        w._.deviceidx = w._.deviceidx or _.deviceidx
                    end
                end
                
                rawset(t,k,v)
            end
        end
    })

    return o
end
