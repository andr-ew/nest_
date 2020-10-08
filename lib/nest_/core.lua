-- _obj_ is a base object for all the types on this page that impliments concatenative prototypical inheritance. all subtypes of _obj_ have proprer copies of the tables in the prototype rather than delegated pointers, so changes to subtype members will never propogate up the tree

-- GOTCHA: overwriting an existing table value will not format type. if we do this, just make sure the type, p, k is correct

local tab = require 'tabutil'

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
            elseif not v.new then -- test !
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
            elseif _[k] ~= nil then return _[k]
            elseif self[k] ~= nil then return self[k]
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
                o[k] = formattype(o, k, clone) ----
            else rawset(o,k,v) end 
        end
    end
    
    return o
end

_input = _obj_:new {
    is_input = true,
    transform = nil,
    handler = nil,
    devk = nil,
    update = function(self, devk, args)
        if(self.devk == devk) then
            return args
        else return nil end
    end
}

function _input:new(o)
    o = _obj_.new(self, o, _obj_)
    local _ = o._

    _.control = nil
    _.devs = {}
    
    local mt = getmetatable(o)
    local mtn = mt.__newindex

    mt.__index = function(t, k) 
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        else
            local c = _.control and _.control[k]
            
            -- catch shared keys, otherwise privilege control keys
            if k == 'new' or k == 'update' or k == 'draw' or k == 'throw' then return self[k]
            else return c or self[k] end
        end
    end

    mt.__newindex = function(t, k, v)
        local c = _.control and _.control[k]
    
        if c and type(c) ~= 'function' then _.control[k] = v
        else mtn(t, k, v) end
    end

    return o
end

_output = _obj_:new {
    is_output = true,
    transform = nil,
    redraw = nil,
    devk = nil,
    throw = function(self, ...)
        self.control.throw(self.control, self.devk, ...)
    end,
    draw = function(self, devk)
        if(self.devk == devk) then
            return {}
        else return nil end
    end
}

_output.new = _input.new

_control = _obj_:new {
    is_control = true,
    v = 0,
    z = 0,
    en = true,
    device = nil,
    action = function(s, v) end,
    init = function(s) end,
    help = function(s) end,
    do_init = function(self)
        self:init()
    end,
    update = function(self, devk, args)
        local d = false

        for i,v in ipairs(self.inputs) do
            local hargs = v:update(devk, args)
            
            if hargs ~= nil then
                d = true
                
                -- change
                if self.metacontrols and not self.metacontrols_disabled then
                    for i,w in ipairs(self.metacontrols) do
                        w:pass(v.handler, hargs)
                    end
                end

                if v.handler then v:handler(table.unpack(hargs)) end
            end
        end
        
        -- call action(s), set v, set dirty flag
    end,
    draw = function(self, devk)
        for i,v in ipairs(self.outputs) do
            local rdargs = v:draw(devk)
            if rdargs ~= nil and v.redraw then v:redraw(table.unpack(rdargs)) end
        end
    end,
    throw = function(self, devk, method, ...)
        if self.catch and self.devk == devk then
            self:catch(devk, method, ...)
        else self.p:throw(devk, method, ...) end
    end,
    print = function(self) end,
    get = function(self) return self.v end,
    set = function(self, v, silent)
        self.v = v
        silent = silent or false

        if not silent then
            self:action(v, self.meta)
            
            -- update dirty flag
        end
    end,
    write = function(self) end,
    read = function(self) end,
    inputs = {},
    outputs = {}
}

function _control:new(o)
    o = _obj_.new(self, o, _obj_)
    local _ = o._    

    _.devs = {}

    ---rm
    local mt = getmetatable(o)
    local mti = mt.__index

    mt.__index = function(t, k) 
        if k == "input" then return o.inputs[1]
        elseif k == "output" then return o.outputs[1]
        elseif k == "target" then return o.targets[1]
        else return mti(t, k) end
    end
    ---/rm

    --mt.__tostring = function(t) return '_control' end

    for i,k in ipairs { "input", "output" } do -- lost on i/o table overwrite, fix in mt.__newindex
        local l = o[k .. 's']

        if rawget(o, k) then 
            rawset(l, 1, rawget(o, k))
            rawset(o, k, nil)
        end
        
        for i,v in ipairs(l) do
            if type(v) == 'table' and v['is_' .. k] then
                rawset(v._, 'control',  o)
                v.devk = v.devk or _.device and _.device.devk or nil
            end
        end

        local lmt = getmetatable(l)
        local lmtn = lmt.__newindex

        lmt.__newindex = function(t, kk, v)
            lmtn(t, kk, v)

            if type(v) == 'table' and v['is_' .. k] then
                v._.control = o
                v.devk = v.devk or o.device and o.device.devk or nil
            end
        end
    end
 
    return o
end

_metacontrol = _control:new {
    pass = function(self, sender, package) end,
    targets = {},
    mode = 'handler' -- or 'v'
}

function _metacontrol:new(o)
    o = _control.new(self, o)

    local mt = getmetatable(o)
    mt.__tostring = function() return '_metacontrol' end

    local tmt = getmetatable(o.targets)
    local tmtn = mt.__newindex

    tmt.__newindex = function(t, k, v)
        tmtn(t, k, v)

        if v.is_control or v.is_nest then 
            if v._.metacontrols == nil then v._.metacontrols = {} end
            table.insert(v.metacontrols, o)
        end

    end

    return o
end

local pt = include 'lib/pattern_time'

_pattern = _metacontrol:new {
    event = _obj_:new {
        path = nil,
        package = nil
    },
    pass = function(self, sender, package) 
        self.pattern_time.watch(self.event:new {
            path = sender:path(target),
            package = package
        })
    end,
    process = function(self, event) 
    end,
    pass = function() end
    rec = function() end,
    loop = function() end,
    rate = function() end,
    play = function() end,
    quantize = function() end
}

function _pattern:new(o) 
    o = _obj_.new(self, o)

    o.pattern_time = pt.new()
end

nest_ = _obj_:new {
    do_init = function(self)
        self:init()
        table.sort(self, function(a,b) return a.z < b.z end)

        for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
    end,
    init = function(self) return self end,
    each = function(self, cb) return self end,
    update = function(self, devk, args)
        for k,v in pairs(self) do if v.is_nest or v.is_control then
            v:update(devk, args )
        end end
    end,
    draw = function(self, devk)  
        for k,v in pairs(self) do if v.is_nest or v.is_control then
            v:draw(devk)
        end end
    end,
    throw = function(self, devk, method, ...)
        self.p:throw(devk, method, ...)
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
    _.z = 0
    _.devs = {}

    local mt = getmetatable(o)
    --mt.__tostring = function(t) return 'nest_' end

    return o
end

_device = _obj_:new {}

function _device:new(o)
    o = _obj_.new(self, o, _device)
    local _ = o._ 

    _.is_device = true
    _.devk = ""

    local mt = getmetatable(o)
    local mtn = mt.__newindex

    mt.__newindex = function(t, k, v)
        mtn(t, k, v)

        if type(v) == "table" then
            if  v.is_control then
                v._.device = t
               
                for i,w in ipairs(v.inputs) do
                    w.devk = w.devk or _.devk
                end
                for i,w in ipairs(v.outputs) do
                    w.devk = w.devk or _.devk
                end
            elseif v.is_device then
                v._.devk = _.devk
            end
        end 
    end
    return o
end

_dev = _obj_:new {
    dirty = true,
    object = nil,
    redraw = nil,
    handler = nil
}
