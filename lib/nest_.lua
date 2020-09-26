-- _obj_ is a base object for all the types on this page that impliments concatenative programming. all subtypes of _obj_ have proprer copies of the tables in the prototype rather than delegated pointers, so changes to subtype members will never propogate up the tree

-- GOTCHA: overwriting an existing table value will not format type. if we do this, just make sure the type, p, k is correct

_obj_ = {
    print = function(self) print(tostring(self)) end
}
function _obj_:new(o, clone_type)
    local _ = { -- the "instance table" - useful as it is ignored by the inheritance rules, and also hidden in subtables
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
            elseif self[k] ~= nil then return self[k]
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
    
    for k,v in pairs(o) do formattype(o, k, v) end -- stack overflow on c:new()

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
    local _ = o._
    
    local mt = getmetatable(o)
    local mti = mt.__index

    mt.__index = function(t, k) 
        local i = mti(t, k) 

        if i then return i
        elseif _.control and _.control[k] then return _.control[k]
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

        if k == "input" then return o.inputs[1]
        elseif k == "output" then return o.outputs[1]
        elseif k == "target" then return o.targets[1]
        elseif i then return i
        else return findmeta(_.p) end
    end

    --mt.__tostring = function(t) return '_control' end

    -- something in here breaks cloning for .inputs[x]
    for i,k in ipairs { "input", "output" } do -- lost on i/o table overwrite, fix in mt.__newindex
        local l = o[k .. 's']
        
        if rawget(o, k) then 
            rawset(l, 1, rawget(o, k)) -- this line !! weird
            rawset(o, k, nil)
        end

        for i,v in ipairs(l) do
            if type(v) == 'table' and v['is_' .. k] then
                v._.control = o
                v.deviceidx = v.deviceidx or _.group and _.group.deviceidx or nil
            end
        end

        local lmt = getmetatable(l)
        local lmtn = lmt.__newindex

        lmt.__newindex = function(t, kk, v)
            lmtn(t, kk, v)

            if type(v) == 'table' and v['is_' .. k] then
                v._.control = o
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

    local mt = getmetatable(o)
    mt.__tostring = function() return '_metacontrol' end

    local tmt = getmetatable(o.targets)
    local tmtn = mt.__newindex

    tmt.__newindex = function(t, k, v)
        tmtn(t, k, v)

        local mct
        if v.is_nest then
            if v._._meta == nil then v._._meta = {} end
            if v._._meta.metacontrols == nil then v._._meta.metacontrols = {} end
            mct = v._._meta.metacontrols
        elseif v.is_control then 
            if v.metacontrols == nil then v.metacontrols = {} end
            mct = v.metacontrols
        end

        table.insert(mct, o)
    end

    return o
end

nest_ = _obj_:new {
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
    write = function(self) end,
    read = function(self) end
}

function nest_:new(o)
    o = _obj_.new(self, o, nest_)
    local _ = o._ 

    _.is_nest = true
    _.en = true
    _.order = 0

    local mt = getmetatable(o)
    --mt.__tostring = function(t) return 'nest_' end

    return o
end

_group = _obj_:new {}
function _group:new(o)
    o = _obj_.new(self, o, _group)
    local _ = o._ 

    _.is_group = true
    _.deviceidx = ""

    local mt = getmetatable(o)
    local mtn = mt.__newindex

    mt.__newindex = function(t, k, v)
        mtn(t, k, v)

        if type(v) == "table" then
            if  v.is_control then
                v._.group = t
               
                for i,w in ipairs(v.inputs) do
                    w.deviceidx = w.deviceidx or _.deviceidx
                end
                for i,w in ipairs(v.outputs) do
                    w.deviceidx = w.deviceidx or _.deviceidx
                end
            elseif v.is_group then
                v._.deviceidx = _.deviceidx
            end
        end 
    end
    return o
end
