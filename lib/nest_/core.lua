-- _obj_ is a base object for all the types on this page that impliments concatenative prototypical inheritance. all subtypes of _obj_ have proprer copies of the tables in the prototype rather than delegated pointers, so changes to subtype members will never propogate up the tree

-- GOTCHA: overwriting an existing table value will not format type. instead, use :replace()

local tab = require 'tabutil'

local function formattype(t, k, v, clone_type) 
    if type(v) == "table" then
        if v.is_obj then 
            v._.p = t
            v._.k = k
        elseif not v.new then -- test !
            v = clone_type:new(v)
            v._.p = t
            v._.k = k
        end

        for i,w in ipairs(t._.zsort) do 
            if w.k == k then table.remove(t._.zsort, i) end
        end
        
        t._.zsort[#t._.zsort + 1] = v
    end

    return v
end

local function zcomp(a, b) 
    if type(a) == 'table' and type(b) == 'table' and a.z and b.z then
        return a.z > b.z 
    else return false end
end

local function nickname(k) 
    if k == 'v' then return 'value' else return k end
end

local function index_nickname(t, k) 
    if k == 'v' then return t.value end
end

local function format_nickname(t, k, v) 
    if k == 'v' and not rawget(t, 'value') then
        rawset(t, 'value', v)
        t['v'] = nil
    end
    
    return v
end

_obj_ = {
    print = function(self) print(tostring(self)) end,
    replace = function(self, k, v)
        rawset(self, k, formattype(self, k, v, self._.clone_type))
    end,
    remove = function(self, k)
        self[k] = nil

        for i,w in ipairs(self._.zsort) do 
            if w.k == k then table.remove(self._.zsort, i) end
        end
    end,
    copy = function(self, o) 
        for k,v in pairs(self) do 
            if rawget(o, k) == nil then
                --if type(v) == "function" then
                    -- function pointers are not copied, instead they are referenced using metatables only when the objects are heierchachically related
                --else
                if type(v) == "table" and v.is_obj then
                    local clone = self[k]:new()
                    o[k] = formattype(o, k, clone, o._.clone_type) ----
                else rawset(o,k,v) end 
            end
        end

        table.sort(o._.zsort, zcomp)

        return o
    end
}

function _obj_:new(o, clone_type)
    local _ = { -- the "instance table" - useful as it is ignored by the inheritance rules, and also hidden in subtables
        is_obj = true,
        p = nil,
        k = nil,
        z = 0,
        zsort = {}, -- list of obj children sorted by descending z value
        clone_type = clone_type,
    }

    o = o or {}
    _.clone_type = _.clone_type or _obj_

    setmetatable(o, {
        __index = function(t, k)
            if k == "_" then return _
            elseif index_nickname(t,k) then return index_nickname(t,k)
            elseif _[k] ~= nil then return _[k]
            --elseif self[k] ~= nil then return self[k]
            else return nil end
        end,
        __newindex = function(t, k, v)
            if _[k] ~= nil then rawset(_,k,v) 
            elseif index_nickname(t, k) then
                rawset(t, nickname(k), formattype(t, nickname(k), v, _.clone_type)) 
            else
                rawset(t, k, formattype(t, k, v, _.clone_type)) 
                
                table.sort(_.zsort, zcomp)
            end
        end,
        __concat = function (n1, n2)
            for k, v in pairs(n2) do
                n1[k] = v
            end
            return n1
        end,
        __call = function(idk, ...) -- dunno what's going on w/ the first arg to this metatmethod
            return o:new(...)
        end,
        --__tostring = function(t) return tostring(t.k) end
    })

    --[[
    
    the parameter proxy table - when accesed this empty table aliases to the object, but if the accesed member is a function, the return value of the function is returned, rather than the function itself

    ]]
    _.p_ = {}

    local function resolve(s, f, ...) 
        if type(f) == 'function' then
            return resolve(s, f(s, ...))
        else return f end
    end

    setmetatable(_.p_, {
        __index = function(t, k) 
            if o[k] then
                return resolve(o, o[k])
            end
        end,
        __call = function(idk, k, ...)
            if o[k] then
                return resolve(o, o[k], ...)
            end
        end,
        __newindex = function(t, k, v) o[k] = v end
    })
    
    for k,v in pairs(o) do 
        formattype(o, k, v, _.clone_type) 
        format_nickname(o, k, v)
    end

    o = self:copy(o)

    return o
end

_input = _obj_:new {
    is_input = true,
    handler = nil,
    devk = nil,
    filter = function(self, devk, args) return args end,
    update = function(self, devk, args, ob)
        if (self.enabled == nil or self.p_.enabled == true) and self.devk == devk then
            local hargs = self:filter(args)
            
            if hargs ~= nil then
                if self.handler then 
                    return hargs, table.pack(self:handler(table.unpack(hargs)))
                end
            end
        end
    end
}

function _input:new(o)
    o = _obj_.new(self, o, _obj_)
    local _ = o._

    --_.p = nil
    _.devs = {}
    
    local mt = getmetatable(o)
    local mtn = mt.__newindex

    mt.__index = function(t, k) 
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        else return _.p and _.p[k]
            --[[
            local c = _.p and _.p[k]
            
            -- catch shared keys, otherwise privilege affordance keys
            if k == 'new' or k == 'update' or k == 'draw' or k == 'devk' then return self[k]
            else return c or self[k] end
            ]]--
        end
    end

    mt.__newindex = function(t, k, v)
        local c = _.p and _.p[k]
    
        if c then _.p[k] = v
        else mtn(t, k, v) end
    end

    return o
end

_output = _obj_:new {
    is_output = true,
    redraw = nil,
    devk = nil,
    draw = function(self, devk, t)
        if (self.enabled == nil or self.p_.enabled) and self.devk == devk then
            if self.redraw then self.devs[devk].dirty = self:redraw(self.devs[devk].object, self.v, t) or self.devs[devk].dirty end -- refactor dirty flag set
        end
    end,
    --[[
    -- this is a tiny bit of a gotcha since it breaks layering, but for now it feels worth saving the cycles -- maybe I'll factor this out later
    draw_clean = function(self, f, ...)
        if (self.enabled == nil or self.p_.enabled) then
            local d = self.devs[self.devk]
            f(d.object, self.v, ...)
            d:refresh()
        end
    end
    --]]
}

_output.new = _input.new

local nest_id = 0 -- incrimenting numeric ID assigned to every nest_ instantiated

local function nextid()
    nest_id =  nest_id + 1
    return nest_id
end

nest_ = _obj_:new {
    init = function(self)
        for i,v in ipairs(self.zsort) do if type(v) == 'table' then if v.init then v:init() end end end
    end,
    --init = function(self) return self end,
    each = function(self, f) 
        for k,v in pairs(self) do 
            local r = f(k, v)
            if r then self:replace(k, r) end
        end

        return self 
    end,
    update = function(self, devk, args, ob)
        if self.enabled == nil or self.p_.enabled == true then
            if self.observable then 
                for i,v in ipairs(self.ob_links) do table.insert(ob, v) end
            end 

            for i,v in ipairs(self.zsort) do 
                if v.update then
                    v:update(devk, args, ob)
                end
            end
        end
    end,
    refresh = function(self, silent)
        local ret
        for i,v in ipairs(self.zsort) do 
            if v.refresh then
                ret = v:refresh(silent) or ret
            end
        end

        return ret
    end,
    draw = function(self, devk)
        for i,v in ipairs(self.zsort) do
            if self.enabled == nil or self.p_.enabled == true then
                if v.draw then
                    v:draw(devk)
                end
            end
        end
    end,
    path = function(self, pathto)
        local p = {}

        local function look(o)
            if (not o.p) or (pathto and pathto.id == o.id) then
                return p
            else
                table.insert(p, 1, o.k)
                return look(o.p)
            end
        end

        return look(self)
    end,
    find = function(self, path)
        local p = self
        for i,k in ipairs(path) do
            if p[k] then p = p[k] 
            else 
                print(self.k or "global" .. ": can't find " .. k) 
                p = nil
                break
            end
        end

        return p
    end,
    set = function(self, t, silent) 
        for k,v in pairs(t) do
            if self[k] and type(self[k]) == 'table' and self[k].is_obj and self[k].set then
                self[k]:set(v, silent)
            end
        end
    end,
    get = function(self, silent, test)
        if test == nil or test(self) then
            local t = _obj_:new()
            for i,v in ipairs(self.zsort) do
                if v.is_obj and rawget(v, 'get') then t[v.k] = v:get(silent, test) end
            end
            return t
        end
    end,
    observable = true,
    persistent = true,
    write = function(self) end,
    read = function(self) end
}

function nest_:new(o, ...)
    local clone_type

    if o ~= nil and type(o) ~= 'table' then 
        local arg = { o, ... }
        o = {}

        if type(o) == 'number' and #arg <= 2 then 
            local min = 1
            local max = 1
            
            if #arg == 1 then max = arg[1] end
            
            if #arg == 2 then 
                min = arg[1]
                max = arg[2]
            end
            
            for i = min, max do
                o[i] = nest_:new()
            end
        else
            for _,k in arg do o[k] = nest_:new() end
        end
    else
       clone_type = ...
    end

    o = _obj_.new(self, o, clone_type or nest_)
    local _ = o._ 

    _.is_nest = true
    _.id = nextid()
    _.enabled = true
    _.devs = {}
    _.observable = true
    _.ob_links = {}

    local mt = getmetatable(o)
    --mt.__tostring = function(t) return 'nest_' end
    
    return o
end

local function runaction(self, aargs)
    self.v = self.action and self.action(self, table.unpack(aargs)) or aargs[1]
    self:refresh(true)
end

local function clockaction(self, aargs)
    if self.p_.clock then
        if type(self.clock) == 'number' then clock.cancel(self.clock) end
        self.clock = clock.run(runaction, self, aargs)
    else runaction(self, aargs) end
end

_affordance = nest_:new {
    value = 0,
    devk = nil,
    action = nil,
    print = function(self) end,
    init = function(self)
        self:refresh()

        nest_.init(self)
    end,
    draw = function(self, devk)
        if self.enabled == nil or self.p_.enabled == true then
            if self.output then
                self.output:draw(devk)
            end
        end
    end,
    update = function(self, devk, args, ob)
        if self.enabled == nil or self.p_.enabled == true then
            if self.observable then 
                for i,v in ipairs(self.ob_links) do table.insert(ob, v) end
            end 

            if self.input then
                local hargs, aargs = self.input:update(devk, args, ob)

                if aargs and aargs[1] then 
                    clockaction(self, aargs)
                    
                    if self.observable then
                        for i,w in ipairs(ob) do
                            if w.p.id ~= self.id then 
                                w:pass(self, self.v, hargs, aargs)
                            end
                        end
                    end
                end
            end
        end
    end,
    refresh = function(self, silent)
        if (not silent) and self.action then
            local defaults = self.arg_defaults or {}
            clockaction(self, { self.v, table.unpack(defaults) })
        else
            for i,v in ipairs(self.zsort) do 
                if v.is_output and self.devs[v.devk] then 
                    self.devs[v.devk].dirty = true
                    if v.handler then v:handler(self.v) end
                end
            end
        end
    end,
    get = function(self, silent, test)
        if test == nil or test(self) then
            local t = nest_.get(self, silent)

            t.value = type(self.value) == 'table' and self.value:new() or self.value -- watch out for value ~= _obj_ !
            if silent == false then self:refresh(false) end

            return t
        end
    end,
    set = function(self, t, silent)
        nest_.set(self, t, silence)

        if t.value then 
            if type(t.value) == 'table' then self.value = t.value:new()
            else self.value = t.value end
        end

        self:refresh(silent)
    end
    --[[
    get = function(self, silent) 
        if not silent then
            return self:refresh()
        else return self.v end
    end,
    set = function(self, v, silent)
        self:replace('v', v or self.v)
        if not self.silent then return self:refresh() end
    end
    --]]
}

function _affordance:new(o)
    o = nest_.new(self, o, _obj_)
    local _ = o._    

    _.devs = {}
    _.is_affordance = true
    --_.clone_type = _obj_

    local mt = getmetatable(o)
    local mtn = mt.__newindex

    --mt.__tostring = function(t) return '_affordance' end

    return o
end

function _affordance:copy(o)
    o = nest_.copy(self, o)

    for k,v in pairs(o) do
        if type(v) == 'table' then if v.is_input or v.is_output or v.is_observer then
            --rawset(v._, 'affordance', o)
            v.devk = v.devk or o.devk
        end end
    end

    return o
end

_observer = _obj_:new {
    is_observer = true,
    --pass = function(self, sender, v, hargs, aargs) end,
    target = nil,
    capture = nil
}

function _observer:new(o)
    o = _input.new(self, o)

    local _ = o._    
    local mt = getmetatable(o)
    local mtn = mt.__newindex
    
    --mt.__tostring = function() return '_observer' end
    
    --[[
    mt.__index = function(t, k) 
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        elseif _.p and _.p[k] ~= nil then return _.p[k]
        elseif _.p and _.p.p and _.p.p[k] ~= nil then return _.p.p[k] --hackk
        end
    end
    --]]

    --[[
    mt.__newindex = function(t, k, v)
        if k == 'target' then 
            vv = t._p[k]

            if type(vv) == 'table' and vv.is_nest then 
                table.insert(vv._.ob_links, o)
            end
        else
            mtn(t, k, v)
        end
    end
    --]]
    
    return o
end

function _observer:init()
    if self.target then
        vv = self.p_.target

        if type(vv) == 'table' and vv.is_nest then 
            table.insert(vv._.ob_links, self)
        end
    end
end

_preset = _observer:new { 
    capture = 'value',
    state = nest_:new(), -- may be one or two levels deep
    --[[
    pass = function(self, sender, v)
        local o = state[self.v]:find(sender:path(self.target))
        if o then
            o.value = type(v) == 'table' and v:new() or v
        end
    end,
    --]]
    store = function(self, x, y) 
        local test = function(o) 
            return o.p_.observers_enabed and o.id ~= self.id
        end
        
        if y then
            self.state[x]:replace(y, self.p_.target:get(true, test))
        else
            self.state:replace(x, self.p_.target:get(true, test))
        end
    end,
    recall = function(self, x, y)
        if y then
            self.p_.target:set(self.state[x][y], false)
        else
            self.p_.target:set(self.state[x], false)
        end
    end,
    --[[
    clear = function(self, n)
        self.state:remove(n) --- meh, i wish zsort wasn't so annoying :/
    end,
    copy = function(self, n_src, n_dest)
        self.state:replace(n_src, self.state[n_dest]:new())
    end,
    --]]
    get = function(self, silent, test) 
        if test == nil or test(self) then
            return _obj_:new { state = self.state:new() }
        end
    end,
    set = function(self, t)
        if t.state then
            self.state = t.state:new()
        end
    end
}

local pattern_time = require 'pattern_time'

function pattern_time:resume()
    if self.count > 0 then
          --print("start pattern ")
        self.prev_time = util.time()
        self.process(self.event[self.step])
        self.play = 1
        self.metro.time = self.time[self.step] * self.time_factor
        self.metro:start()
    end
end

_pattern = _observer:new {
    pass = function(self, sender, v, hargs, aargs) 
        local package
        if self.capture == 'value' then
            package = type(v) == 'table' and v:new() or v
        elseif self.capture == 'action' then
            package = _obj_:new()
            for i,w in ipairs(aargs) do
                package[i] = type(w) == 'table' and w:new() or w
            end
        else
            package = hargs
        end

        self:watch(_obj_:new {
            path = sender:path(self.p_.target),
            package = package 
        })
    end,
    proc = function(self, e)
        local o = self.p_.target:find(e.path)
        local p = e.package

        if o then
            if self.capture == 'value' then
                o.value = type(p) == 'table' and p:new() or p
                o:refresh(false)
            elseif self.capture == 'action' then
                clockaction(o, p)
            else
                clockaction(o, table.pack(o.input:handler(table.unpack(p))))
            end
        else print('_pattern: path error') end
    end,
    get = function(self, silent, test) 
        if test == nil or test(self) then
            local t = _obj_:new { event = {}, time = {}, count = self.count, step = self.step }

            for i = 1, self.count do
                t.time[i] = self.time[i]
                t.event[i] = self.event[i]:new()
            end
        end
    end,
    set = function(self, t)
        if t.event then
            self.count = t.count
            self.step = t.step
            for i = 1, t.count do
                self.time[i] = t.time[i]
                self.event[i] = t.event[i]:new()
            end
        end
    end
}

function _pattern:new(o) 
    o = _observer.new(self, o)

    local pt = pattern_time.new()
    pt.process = function(e) 
        o:proc(e) 
    end

    local mt = getmetatable(o)
    local mti = mt.__index
    local mtn = mt.__newindex

    --alias _pattern to pattern_time instance
    mt.__index = function(t, k)
        if k == 'new' then return mti(t, k)
        elseif pt[k] ~= nil then return pt[k]
        else return mti(t, k) end
    end
    
    mt.__newindex = function(t, k, v)
        if k == 'new' then mtn(t, k, v)
        elseif pt[k] ~= nil then pt[k] = v
        else mtn(t, k, v) end
    end

    return o
end

_group = _obj_:new {}

function _group:new(o)
    o = _obj_.new(self, o, _group)
    local _ = o._ 

    _.is_group = true
    _.devk = ""

    local mt = getmetatable(o)
    local mtn = mt.__newindex

    mt.__newindex = function(t, k, v)
        mtn(t, k, v)

        if type(v) == "table" then
            if v.is_affordance then
                for l,w in pairs(v) do
                    if type(w) == 'table' then
                        if w.is_input or w.is_output and not w.devk then 
                            w.devk = _.devk 
                        end
                    end
                end

                v.devk = _.devk
            elseif v.is_group or v.is_input or v.is_output then
                v.devk = _.devk
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
