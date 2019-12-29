nest_ = {}
function nest_:new(o)
    local _ = {
        is_nest = true,
        p = self,
        parent = self,
        enabled = true
    }
    
    o = o or {}
    
    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end
        
    function nestify(parent, v)
        if type(v) == "table" then
            if v.is_control then
            elseif v.is_nest then 
            else
                v = nest_:new(v)

                rawset(o, "parent", table)
                rawset(o, "p", table)
            end
        end
    end
    
    setmetatable(o, self)
    
    self.__index = function(t, k)
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        else return rawget(self, k) end
    end

    self.__newindex = function(t, k, v)
        nestify(t, v)
        rawset(t,k,v)
    end
    
    for k,v in pairs(o) do nestify(o, v) end

    return o
end

_input = {}
function _input:new(o)
    local _ = {
        is_input = true,
        control = {},
        enabled = true
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
        control = {},
        enabled = true
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

_control = {}
function _control:new(o)
    local _ = {
        is_control = true,
        p = self,
        parent = self,
        inputs = {},
        outputs = {},
        target = nil,
        enabled = true
    }
    
    o = o or {}
    
    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end
    
    setmetatable(_.inputs, {
        __newindex = function(t, k, v)
            if v.is_input then
                v.control = self
                rawset(t,k,v)
            end
        end
    })
    
    setmetatable(_.outputs, {
        __newindex = function(t, k, v)
            if v.is_output then
                    v.control = self
                rawset(t,k,v)
            end
        end
    })
    
    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif _[k] ~= nil then return _[k]
        elseif k == "input" then return _.inputs[0]
        elseif k == "output" then return _.outputs[0]
        else return rawget(self, k) end
    end
    
    _.inputs[0] = _input:new()
    _.outputs[0] = _output:new()
    
    _.inputs[0]._.control = self
    _.outputs[0]._.control = self
    
    return o
end

_target = {}
function _target:new(o)
    local _ = {
        enabled = true
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
            v._.target = t
            rawset(t,k,v)
        end
    end
    
    return o
end

_test = _target:new()
_test.control = _control:new()
_test.control._.dooby = "plob"

test_ = nest_:new{
    control = _test.control:new()
}

print(test_.control.dooby)