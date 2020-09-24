--[[

this is gonna be a base object for all the types on this page that is gonna try & impliment concatenative programming. all prototypes of cat will have proprer, immutable copies of the tables in the parent rather than delegated pointers, so changes to prototype members will never propogate up the type tree

to do this, all table members and sub-members must be turned into _obj_s!. (via recursive function). be careful though, this might mess up outside objects. then, cat:new() new will manually assign k = k.new and k:new() or k to all members in self (from prototype to self)

we'll throw in the generally useful members of nest_ (k, p, print(), pathi, ...) as the only instance of a secret table (_) so we don't mess up the keying

]]

--[[

the clone abilities are working for normal _obj_ memebers but it's not deep copying the heiarchy for tables. they are becoming _obj_s but the table is not actually being copied

]]

_obj_ = {}
function _obj_:new(o, clone_type)
    local _ = {
        is_obj = true,
        p = nil,
        k = nil
    }

    local function formattype(t, k, v) 
        if type(v) == "table" then
            if v.is_obj then 
                v._.p = t
                v._.k = k
            else
                v = clone_type:new(v)
                v._.p = t
                v._.k = k
            end
        end

        return v
    end

    o = o or {}
    clone_type = clone_type or _obj_

    setmetatable(o, {
        __index = function(t, k)
            if k == "_" then return _
            elseif self[k] ~= nil then return self[k] --------- stack overflow :/
            elseif _[k] ~= nil then return _[k]
            else return nil end
        end,
        __newindex = function(t, k, v)
            if _[k] ~= nil then rawset(_,k,v) 
            else rawset(t, k, formattype(t, k, v)) end
        end,
        __concat = function (n1, n2)
            for k, v in pairs(n2) do
                n1[k] = v
            end
            return n1
        end--,
        --__tostring = function(t) return '_obj_' end
    })
    
    for k,v in pairs(o) do formattype(o, k, v) end

    for k,v in pairs(self) do 
        if not rawget(o, k) then
            if type(v) == "function" then
            elseif type(v) == "table" then
                local clone = formattype(self, k, v):new()
                rawset(o, k, formattype(o, k, clone))
            else rawset(o,k,v) end 
        end
    end
    
    return o
end

_input = _obj_:new {
    is_input = true,
    control = nil,
    deviceidx = nil,
    transform = nil,
    handler = nil,
    update = function(self, deviceidx, args)
        if(self.deviceidx == deviceidx) then
            return args
        else return nil end
    end
}

function _input:new(o)
    o = _obj_.new(self, o, _obj_)
    
    local mt = getmetatable(o)
    local mti = mt.__index

    mt.__index = function(t, k) 
        local i = mti(t, k) 

        if i then return i
        elseif rawget(t, 'control') and rawget(t, 'control')[k] then return rawget(t, 'control')[k]
        --elseif rawget(t, 'control') and rawget(rawget(t, 'control'), k) then return rawget(rawget(t, 'control'), k) -- this screws things up if we need to call functions inherited into control :/ but it stops the line 46 stack overflow
        else return nil end
    end

    return o
end

_output = _obj_:new {
    is_output = true,
    control = nil,
    deviceidx = nil,
    transform = nil,
    redraw = nil,
    throw = function(self, ...)
        self.control.throw(self.control, self.deviceidx, ...)
    end,
    draw = function(self, deviceidx)
        if(self.deviceidx == deviceidx) then
            return {}
        else return nil end
    end
}

_output.new = _input.new

_control = _obj_:new {
    is_control = true,
    v = 0,
    order = 0,
    en = true,
    group = nil,
    a = function(s, v) end,
    init = function(s) end,
    help = function(s) end,
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
    read = function(self) end,
    inputs = {},
    outputs = {}
}

function _control:new(o)
    o = _obj_.new(self, o, _obj_)
    local _ = o._    

    local mt = getmetatable(o)
    local mti = mt.__index

    mt.__index = function(t, k) 
        local findmeta = function(nest)
            if nest and nest.is_nest then
                if nest._meta ~= nil and nest._meta[k] ~= nil then return nest._meta[k]
                elseif nest._._meta ~= nil and nest._._meta[k] ~= nil then return nest._._meta[k]
                elseif nest._.p ~= nil then return findmeta(nest._.p)
                else return nil end
            else return nil end
        end

        local i = mti(t, k) 
        if i then return i
        elseif k == "input" then return t.inputs[1]
        elseif k == "output" then return t.outputs[1]
        elseif k == "target" then return t.targets[1]
        else return findmeta(_.p) end
--        else return nil end
    end

    --mt.__tostring = function(t) return '_control' end

    for i,k in ipairs { "input", "output" } do
        local l = o[k .. 's']
        
        if o[k] then 
            l[1] = o[k]
            o[k] = nil
        end

        for i,v in ipairs(l) do
            if type(v) == 'table' and v['is_' .. k] then
                rawset(v, 'control', o) -- gotcha!
                v.deviceidx = v.deviceidx or o.group and o.group.deviceidx or nil
            end
        end

        local lmt = getmetatable(l)
        local lmtn = lmt.__newindex

        lmt.__newindex = function(t, kk, v)
            lmtn(t, kk, v)

            if type(v) == 'table' and v['is_' .. k] then
                rawset(v, 'control', o)
                v.deviceidx = v.deviceidx or o.group and o.group.deviceidx or nil
            end
        end
    end

    return o
end

_metacontrol = _control:new {
    pass = function(self, f, args) end,
    --[[

    passing the function will work but not for recall

    ]]
    targets = {}
}

function _metacontrol:new(o)
    o = _control.new(self, o)
    
    --[[
    setmetatable(o.targets, {
        __newindex = function(t, k, v)
            local mt
            if v.is_nest then
                if v._._meta == nil then v._._meta = {} end
                if v._._meta.metacontrols == nil then v._._meta.metacontrols = {} end
                mt = v._._meta.metacontrols
            elseif v.is_control then 
                if v.metacontrols == nil then v.metacontrols = {} end
                mt = v.metacontrols
            end

            table.insert(mt, self)
            rawset(t,k,v)
        end
    })
    ]]

    return o
end

nest_ = {}
function nest_:new(o)
    --[[

    so actually members from the supertype are not picked up by pairs() (duh) which means the secret table is kinda pointless but also means we should probably alter new() to act more 'immutable' by new-ing nest table members of the supertype into the prototype, in the style of inputs{}, outputs{} (also kinda like nestify(), any plain tables should become nest_'s in order to propogate the behaviors

    fwiw, we could even consider adding this behavior to _control, too.

    at this point, nest_ is staring to resemble a blank object with a special / weird object oriented behavior. if we want to extend these behaviors to _control, _input, _output, we might want to restructure these types as prototypes of _nest, ot create a shared supertype which defines only the object oriented behaviors (_obj_ !)
        
    ]]
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
        set = function(self, tv) end, --table set nest = { nest = { control = value } }
        get = function(self) end,
        print = function(self) end,
        write = function(self) end,
        read = function(self) end
    }

    o = o or {}

    local function nestify(p, k, v)
        if type(v) == "table" then
            if v.is_control then v.p = p
            elseif v.is_nest then v._.p = p
            else
                v = nest_:new(v)
                v._.p = p
            end
        end
    end

    local concat = function (n1, n2)
        for k, v in pairs(n2) do
            n1[k] = v
        end
        return n1
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
        __tostring = function(t) return 'nest_' end
    })

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
                    v.group = t
                   
                    for i,w in ipairs(v.inputs) do
                        w.deviceidx = w.deviceidx or _.deviceidx
                    end
                    for i,w in ipairs(v.outputs) do
                        w.deviceidx = w.deviceidx or _.deviceidx
                    end
                end
                
                rawset(t,k,v)
            end
        end
    })

    return o
end
