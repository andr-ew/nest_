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

    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end

    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif rawget(self, k) ~= nil then return rawget(self, k)
        elseif _[k] ~= nil then return _[k]
        elseif _.control[k] ~= nil then return _.control[k]
        else return nil end
    end

    return o, _
end

_output = {}
function _output:new(o)
    local _ = {
        is_output = true,
        control = nil,
--        transform = function(v) return v end,
--        redraw = function(self) end,
        throw = function(self, ...)
            self._.control._.throw(self._.control, self.deviceidx, unpack(arg))
        end,
        draw = function(self, deviceidx)
            if(self._.deviceidx == deviceidx) then
                return true 
            else return nil end
        end
    }

    o = o or {}

    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end

    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif rawget(self, k) ~= nil then return rawget(self, k)
        elseif _[k] ~= nil then return _[k]
        elseif _.control[k] ~= nil then return _.control[k]
        else return nil end
    end
    return o, _
end

-- refactor to use short names internally
-- x, y, v, lvl, a, en, ctrl 

_control = {
    value = 0,
    action = function(s, v) end,
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
                    v:handler(unpack(hargs))
                end
            end

            if d then for i,v in ipairs(self.outputs) do
                self.device_redraws[deviceidx]()
            end end
        end,
        draw = function(self, deviceidx)
            for i,v in ipairs(self.outputs) do
                local rdargs = v:draw(deviceidx)
                if rdargs ~= nil then v:redraw(rdargs) end
            end
        end,
        throw = function(self, deviceidx, method, ...)
            if self.catch and self.deviceidx == deviceidx then
                self:catch(deviceidx, method, unpack(arg))
            else self.parent:throw(deviceidx, method, unpack(arg)) end
        end,
        print = function(self) end,
        get = function(self) return self.value end,
        set = function(self, v, silent)
            self.value = v
            silent = silent or false

            if not silent then
                self:action(v, self.meta)

                if d then for i,v in ipairs(self.outputs) do
                    self.device_redraws[deviceidx]()
                end end
            end
        end,

        --[[
        
        add param = nil
        add :link(param.id)
            set param to param
            set v to param.value
            set get & set to param .get & .set
            overwrite param.action to update self, run self.action
        end

        ]]

        write = function(self) end,
        read = function(self) end
    }

    o = o or {}

    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end
    setmetatable(o, self)

    setmetatable(o.inputs, {
        __newindex = function(t, k, v)
            if v.is_input then
                v._.control = o
                v._.deviceidx = o._.deviceidx
                rawset(t,k,v)
            end
        end
    })

    setmetatable(o.outputs, {
        __newindex = function(t, k, v)
            if v.is_output then
                v._.control = so
                v._.deviceidx = o._.deviceidx
                rawset(t,k,v)
            end
        end
    })

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
                if nest._._meta ~= nil and nest._._meta[k] ~= nil then return nest._._meta[k]
                elseif nest.parent ~= nil then return findmeta(nest.parent)
                else return nil end
            end
        end

        -- rename nickname keys in o, maybe make a central table lookup
        if k == "_" then return _
        elseif k == "i" then return _.index
        elseif k == "p" then return _.parent
        elseif k == "v" then return t.value
        elseif k == "a" then return t.action
        elseif k == "o" then return t.order
        elseif k == "en" then return t.enabled
        elseif k == "input" then return t.inputs[1]
        elseif k == "output" then return t.outputs[1]
        elseif k == "target" then return t.targets[1]
        elseif rawget(self, k) ~= nil then return rawget(self, k)
        elseif _[k] ~= nil then return _[k]
        elseif findmeta(_.parent) ~= nil then return findmeta(_.parent)
        else return nil end
    end

    for i,v in ipairs(o.inputs) do
        v._.control = o
        v._.deviceidx = o._.deviceidx
    end
    for i,v in ipairs(o.outputs) do
        v._.control = o
        v._.deviceidx = o._.deviceidx
    end

    return o, _
end

_metacontrol = {
    targets = {} 
}
function _metacontrol:new(o)
    local _ = nil
    o, _ = _control:new(o)
    
    _.is_metacontrol = true
    _.pass = function(self, f, args) end
    --[[

    passing the function will work but not for recall, create the global registry_ nest as a lookup & absolute identifier for all controls

    this means multiple .index + parent's will need to be supported (nice to have anyway), set the registry as parents[0], indicies[0]

    devices could even be connected to the registry. now that is a thought.

     ]]
    _.metacontrols_disabled = true
    
    setmetatable(o.targets, {
        __newindex = function(t, k, v)
            local mt
            if v.is:_nest then
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
end

nest_ = {}
function nest_:new(o)
    local _ = {
        do_init = function(self)
            self:init()
            table.sort(self, function(a,b) return a.order < b.order end)

            for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
        end,
        connect = function(self, devices) end,
        init = function(self) end,
        each = function(self, cb) end,
        is_nest = true,
        index = nil,
        parent = nil,
        enabled = true,
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
            self.parent:throw(deviceidx, method, unpack(arg))
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

    -- rename nickname keys in o
    self.__index = function(t, k)
        if k == "_" then return _
        elseif k == "i" then return _.index
        elseif k == "p" then return _.parent
        elseif k == "o" then return _.order
        elseif k == "en" then return _.enabled
        elseif rawget(self, k) ~= nil then return rawget(self, k)
        elseif _[k] ~= nil then return _[k]
        else return nil end
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

    return o, _
end

_group = {}
function _group:new(o)
    local _ = {
        index = nil,
        is_group = true,
        deviceidx = nil
    }

    o = o or {}

    if self._ ~= nil then
        setmetatable(_, self._)
        self._.__index = self._
    end

    setmetatable(o, self)

    self.__index = function(t, k)
        if k == "_" then return _
        elseif rawget(self, k) ~= nil then return rawget(self, k)
        elseif _[k] ~= nil then return _[k]
        else return nil end
    end

    self.__newindex = function(t, k, v)
        if type(v) == "table" and v.is_control then
            for i,w in ipairs(v.inputs) do
                w._.deviceidx = _.deviceidx 
            end
            for i,w in ipairs(v.outputs) do
                w._.deviceidx = _.deviceidx
            end
        end
        
        rawset(t,k,v)
    end

    return o, _
end
