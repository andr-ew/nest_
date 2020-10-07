--[[

RN
a -> action
order -> z ?

CONCEPTS

create _control.__call metatmethod as a set/bang/get function. if first arg is control, ignore it

??? remove inputs{}, outputs{}; _input, _output simply refer to o, p (, meta), then self for members, control searches self for _inputs & _outputs to update ???

add actions{} table, alias action to actions[1] 
OR add actions table as a list of keys in self

add :link(_control or function() return control end) to _control, link two controls by appending actions

when nest_ arg type is not table add a number range or key list argument option to initialize blank table children at specified keys

add :each(function(k, _)) to _obj_. these would run after the top level table has been initialized, which helps to enable absolute paths to be used within a nest structure

or, on the opposite end of the spectrum, remove _meta altogether. with the each() function i'm starting to question why we need this technique ! we would need to repliment connect() as a method which adds devices to all children and grandchildren

convention: allow most data parameters to be a value or a function returning the desired value. current _grid. imlimentations will need to change. to impliment this we can create a blank par table as a proxy. par will index the same as _i/o, but if the value is a function, it'll return the return the return value of the function rather than the function itself

_paramcontrol: subtype of control which can be linked to a param ?

create the devices table and _device object

_device = {
    dirty = true,
    object = grid/arc/screen/enc/key/etc,
    redraw = function() end
}

devices = {
    screen,
    key,
    enc,
    g,
    a,
    m,
    h
}

:connect adds a link to the devices table (table, not _obj_, make sure it doesn't become _obj_) to every child/grandchild as well as g, a, etc (/vport device) links

clean up redraws: rather than redraw on any input, set up a global 30fps redraw metro and a global dirty flag per device. :update() or _control() sets the dirty flag 

add _nest.init = function() end param, init return table members are assigned to _nest

_nest: do_init() -> pre_init() -> init() -> bang

handler(), _control() -> action[1]()i -> ... -> anction[n] -> v (catch nill returns)

in control.update(), pass both the handler args and resulting value to _metacontrol, metacontrol decides what to store and recall. (.mode = 'v' or 'handler' for default pattern control)

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

]]

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
    deviceidx = nil,
    update = function(self, deviceidx, args)
        if(self.deviceidx == deviceidx) then
            return args
        else return nil end
    end
}

function _input:new(o)
    o = _obj_.new(self, o, _obj_)
    local _ = o._

    _.control = nil
    
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
    deviceidx = nil,
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

                if self.metacontrols and not self.metacontrols_disabled then
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

        if k == "input" then return o.inputs[1]
        elseif k == "output" then return o.outputs[1]
        elseif k == "target" then return o.targets[1]
        else return findmeta(_.p) or mti(t, k) end
    end

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
    pass = function(self, sender, package) end,
    targets = {},
    mode = 'handler' -- or 'v'
}

-- will need to set back to old imlimentation when remove _meta
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
        table.sort(self, function(a,b) return a.order < b.order end)

        for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
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
