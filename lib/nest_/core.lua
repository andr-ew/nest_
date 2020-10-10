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
    handler = nil,
    devk = nil,
    filter = function(self, devk, args) return args end,
    update = function(self, devk, args, mc)
        if self.devk == devk then
            local hargs = self:filter(args)
            
            if hargs ~= nil and self.control then
                if self.devs[self.devk] then self.devs[self.devk].dirty = true end
 
                if self.handler then 
                    self.control.v = self:handler(table.unpack(hargs)) or self.control.v
                end

                if self.metacontrols_enabled then
                    for i,w in ipairs(mc) do
                        w:pass(self.control, self.control.v, hargs)
                    end
                end
            end
        end
        
        -- call action(s), set v
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
            if k == 'new' or k == 'update' or k == 'draw' or k == 'devk' then return self[k]
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
    redraw = nil,
    devk = nil,
    draw = function(self, devk)
        if(self.devk == devk) then
            if self.redraw then self:redraw() end
        end
    end
}

_output.new = _input.new

nest_ = _obj_:new {
    do_init = function(self)
        self:init()
        table.sort(self, function(a,b) return a.z < b.z end)

        for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
    end,
    init = function(self) return self end,
    each = function(self, cb) return self end,
    update = function(self, devk, args, mc)
        if self.metacontrols_enabled then 
            for i,v in ipairs(self.mc_links) do table.insert(mc, v) end
        end 

        for k,v in pairs(self) do 
            if type(v) == 'table' then if v.update then
                v:update(devk, args, mc)
            end end
        end
    end,
    draw = function(self, devk)  
        for k,v in pairs(self) do
            if type(v) == 'table' then if v.draw then
                v:draw(devk)
            end end
        end
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
    _.enabled = true
    _.z = 0
    _.devs = {}
    _.metacontrols_enabled = true
    _.mc_links = {}

    local mt = getmetatable(o)
    --mt.__tostring = function(t) return 'nest_' end

    return o
end

_control = nest_:new {
    v = 0,
    z = 0,
    devk = nil,
    action = function(s, v) end,
    init = function(s) end,
    do_init = function(self)
        self:init()
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
    end
}

function _control:new(o)
    o = _obj_.new(self, o, _obj_)
    local _ = o._    

    _.devs = {}
    _.is_control = true

    local mt = getmetatable(o)
    local mtn = mt.__newindex

    --mt.__tostring = function(t) return '_control' end

    mt.__newindex = function(t, k, v) 
        mtn(t, k, v)
        if type(v) == 'table' then if v.is_input or v.is_output then
            rawset(v._, 'control', o)
            v.devk = v.devk or o.devk
        end end
    end

    for k,v in pairs(o) do
        if type(v) == 'table' then if v.is_input or v.is_output then
            rawset(v._, 'control', o)
            v.devk = v.devk or o.devk
        end end
    end
 
    return o
end

_metacontrol = _control:new {
    pass = function(self, sender, v, handler_args) end,
    target = nil,
    mode = 'handler' -- or 'v'
}

function _metacontrol:new(o)
    o = _control.new(self, o)

    local mt = getmetatable(o)
    local mtn = mt.__newindex
    
    --mt.__tostring = function() return '_metacontrol' end

    mt.__newindex = function(t, k, v)
        mtn(t, k, v)

        if k == 'target' then 
            vv = v

            if type(v) == 'functon' then 
                vv = v()
            end

            if type(vv) == 'table' and vv.is_nest then 
                table.insert(vv._.mc_links, o)
            end
        end
    end
    
    if o.target then
        vv = o.target

        if type(o.target) == 'functon' then 
            vv = o.target()
        end

        if type(vv) == 'table' and vv.is_nest then 
            table.insert(vv._.mc_links, o)
        end
    end

    return o
end

--local pt = include 'lib/pattern_time'

_pattern = _metacontrol:new {
    event = _obj_:new {
        path = nil,
        package = nil
    },
    pass = function(self, sender, v, handler_args) 
        self.pattern_time.watch(self.event:new {
            path = sender:path(target),
            package = self.mode == 'v' and v or handler_args
        })
    end,
    process = function(self, event) end,
    pass = function() end,
    rec = function() end,
    loop = function() end,
    rate = function() end,
    play = function() end,
    quantize = function() end
}

function _pattern:new(o) 
    o = _obj_.new(self, o)

    --o.pattern_time = pt.new()
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
            if v.is_control then
                for l,w in pairs(v) do
                    if type(w) == 'table' then
                        if w.is_input or w.is_output then 
                            w.devk = _.devk 
                        end
                    end
                end

                v.devk = _.devk
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
