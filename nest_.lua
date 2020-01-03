_input = {}
function _input:new(o)
    local _ = {
        is_input = true,
        control = nil,
        transform = function(v) return v end,
        check = function(self, args) return false end
    }
    
    o = o or {}
    
    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end

    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        elseif _.control[k] ~= nil then return _.control[k]
        else return rawget(self, k) end
    end
    
    return o
end

_output = {}
function _output:new(o)
    local _ = {
        is_output = true,
        control = nil,
        look = function(self) return false end
    }
    
    o = o or {}
    
    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end

    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        elseif _.control[k] ~= nil then return _.control[k]
        else return rawget(self, k) end
    end
    return o
end

_control = {
    value = 0,
    meta = {},
    event = function(s, v) end,
    order = 0,
    enabled = true,
    init = function(s) end,
    inputs = {},
    outputs = {},
    help = function(s) end
}
function _control:new(o)
    local _ = {
        is_control = true,
        index = nil,
        parent = self,
        do_init = function(self)
            self:init()
        end,
        groupidx = nil,
        metacontrols = {},
        metacontrols_enabled = true,
        check = function(self, groupidx, args, metacontrols) 
            if groupidx == self.groupidx then
                for i,v in ipairs(self.inputs) do
                    if v:check(args) then
                        for i,v in ipairs(metacontrols) do
                            v:pass(self, self.value, self.meta)
                        end
                    end
                end
            end
        end,
        look = function(self, groupidx)
            if groupidx == self.groupidx then
                for i,v in ipairs(self.inputs) do
                    v:look()
                end
            end
        end,
        draw = function(self, method, ...)
            self.parent:draw(self, method, unpack(arg))
        end,
        print = function(self) end,
        set = function(self, v) end,
        write = function(self) end,
        read = function(self) end
    }
    
    o = o or {}
    
    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end
    
    setmetatable(self.inputs, {
        __newindex = function(t, k, v)
            if v.is_input then
                v.control = self
                rawset(t,k,v)
            end
        end
    })
    
    setmetatable(self.outputs, {
        __newindex = function(t, k, v)
            if v.is_output then
                    v.control = self
                rawset(t,k,v)
            end
        end
    })
    
    setmetatable(o, self)
        
    local concat = function (n1, n2)
        for k, v in pairs(n2) do
            n1[k] = v
        end
        return n1
    end
    
    self.__concat = concat
    _.__concat = concat
        
    self.__tostring = function(t) end

    self.__index = function(t, k)
        local findmeta = function(nest)
            if nest.is_nest then
                if nest._meta ~= nil and nest._meta[k] ~= nil then return nest._meta[k]
                elseif nest.parent ~= nil then return findmeta(nest.parent)
                else return nil end
            end
        end
            
        if k == "_" then return _
        elseif k == "i" then return _.index
        elseif k == "p" then return _.parent
        elseif k == "v" then return t.value
        elseif k == "m" then return t.meta
        elseif k == "e" then return t.event
        elseif k == "o" then return t.order
        elseif k == "en" then return t.enabled
        elseif k == "input" then return t.inputs[0]
        elseif k == "output" then return t.outputs[0]
        elseif k == "target" then return t.targets[0]
        elseif _[k] ~= nil then return _[k]
        elseif findmeta(_.parent) ~= nil then return findmeta(_.parent)
        else return rawget(self, k) end
    end
    
    self.inputs[0] = _input:new()
    self.outputs[0] = _output:new()
    
    self.inputs[0]._.control = self
    self.outputs[0]._.control = self
    
    return o
end
    
_metacontrol = _control:new()

_metacontrol.targets = {}
_metacontrol._.is_metacontrol = true
_metacontrol._.pass = function(self, control, value, meta) end

setmetatable(_metacontrol.targets, {
    __newindex = function(t, k, v)
        if v.is_nest or v.is_control then table.insert(v.metacontrols, t)
        end
        rawset(t,k,v)
    end
})

nest_ = {}
function nest_:new(o)
    local _ = {
        roost = function(self) 
            nest_api.roost = self
            self.is_roost = true
        end,
        is_roost = false,
        do_init = function(self)
            self:init()
            for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
        end,
        init = function(self) end,
        each = function(slef, cb) end,
        is_nest = true,
        index = nil,
        parent = nil,
        enabled = true,
        order = 0,
        groupidx = nil,
        metacontrols = {},
        metacontrols_enabled = true,
        check = function(self, groupidx, args, metacontrols)
            if self.metacontrols_enabled and metacontrols ~= nil then
                for i,v in ipairs(self.metacontrols) do table.insert(metacontrols, v) end
            else metacontrols = nil
            end
            
            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:check(groupidx, args, metacontrols)
            end end
        end,
        look = function(self, groupidx) 
            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:look(groupidx)
            end end
        end,
        draw = function(self, control, method, ...)
            if self.is_roost then
                nest_api:draw(control, method, unpack(arg))
            else
                self.parent:draw(control, method, unpack(arg))
            end
        end,
        print = function(self) end,
        write = function(self) end,
        read = function(self) end
    }
    
    o = o or {}
    
    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end
        
    local function nestify(parent, index, v)
        if type(v) == "table" then
            if v.is_control then
            elseif v.is_nest then
            else
                v = nest_:new(v)
            end
            
            rawset(o, "index", index)
            rawset(o, "parent", parent)
        end
    end
    
    setmetatable(o, self)
    
    self.__index = function(t, k)
        if k == "_" then return _
        elseif k == "i" then return _.index
        elseif k == "p" then return _.parent
        elseif k == "o" then return _.order
        elseif k == "en" then return _.enabled
        elseif _[k] ~= nil then return _[k]
        else return rawget(self, k) end
    end

    self.__newindex = function(t, k, v)
        nestify(t, k, v)
        rawset(t,k,v)
    end
    
    local concat = function (n1, n2)
        for k, v in pairs(n2) do
            n1[k] = v
        end
        return n1
    end
    
    self.__concat = concat
    _.__concat = concat
    
    self.__tostring = function(t) end
    
    for k,v in pairs(o) do nestify(o, k, v) end

    return o
end

_group = {}
function _group:new(o)
    local _ = {
        index = nil,
        init = function(self) nest_api:look(self.index) end,
        check = function(self, args) 
            nest_api.roost:check(self.index, args, {})
        end,
        look = function(self, groupidx) 
            nest_api.roost:look(self.index)
        end,
        draw = function(self, method, ...) end
    }
    
    o = o or {}

    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end

    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        else return rawget(self, k) end
    end
    
    self.__newindex = function(t, k, v)
        if v.is_control ~= nil then
            v._.group = t
            rawset(t,k,v)
        end
    end
    
    return o
end

nest_api = {
    check = function(self, groupidx, ...) self.group[control._.groupidx]:check(unpack(arg)) end,
    look = function(self, groupidx) self.group[groupidx]:look() end,
    roost = nil,
    draw = function(self, control, method, ...) self.group[control._.groupidx]:draw(method, control, unpack(arg)) end,
    init = function(self) 
        for k,v in pairs(self.group) do v:init() end
        self.roost:do_init()
    end,
    group = {}
}

setmetatable(nest_api.group, {
    __newindex = function(t, k, v)
        v._.index = k
        _G[k] = v
                
        rawset(t,k,v)
    end
})