_input = {}
function _input:new(o)
    local _ = {
        is_input = true,
        control = nil,
        deviceidx = nil,
        transform = function(v) return v end,
        handler = function(self, ...) return false end,
        update = function(self, deviceidx, args)
            if(self._.deviceidx == deviceidx) then
                return self:handler(unpack(args))
            else return false end
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
        deviceidx = nil,
        transform = function(v) return v end,
        redraw = function(self) return false end,
        throw = function(self, ...)
            self._.control._.throw(self._.control, self.deviceidx, unpack(arg))

            --[[

            lets say that redraw() is welcome to perform draw actions straight on the device in a familiar style ( s.screen.text() ).

            to allow a nest of controls to be reassigned to a different Grid or Arc objects on seprate vports, we'll establish the convention of placing something like:

            _meta = {
                devices = {
                    screen = screen,
                    g = devices.grid[1],
                    a = devices.grid[2]
                },
                screen = screen,
                g = devices.grid[1],
                a = devices.arc[1]
            }

            on the parent nest or nest relevant to a particular device. in redraw, you can access the intended device like this: s.g:led()

            the _meta assignment could be astracted as: nest_:connect(grid.connect(), arc.connect(), screen). this also defines the device handlers to call :update_draw(deviceidx) or :draw() (fka update, draw) on this nest 

:connect { g = grid.connect() }

            in special cases, this function here can be used to 'throw' args up to an elder nest. this nest would have a 'catch()' defined that takes those args & draws to a device (useful for screen UIs, probably other things)

            ]]

        end,
        draw = function(self, deviceidx)
            if(self._.deviceidx == deviceidx) then
                self:redraw() 
            else return false end
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
--        inputs = {},
--        outputs = {},
        is_control = true,
        index = nil,
        parent = self,
        do_init = function(self)
            self:init()
        end,
        deviceidx = nil,
        metacontrols = {}, ----- rm
        metacontrols_enabled = true,
        update = function(self, deviceidx, args, metacontrols) -- metacontrols arg -> self.metacontrols
            for i,v in ipairs(_.inputs) do
                local hargs = v:update(deviceidx, args)

                if hargs ~= nil then
                    for i,v in ipairs(metacontrols) do
                        v:pass(hargs)
                    end

                    v:handler(hargs)

                    for i,v in ipairs(_.outputs) do
                        self.roost:draw(v.deviceidx)
                    end
                end
            end
        end,
        draw = function(self, deviceidx)
            for i,v in ipairs(_.outputs) do
                local hargs = v:draw(deviceidx)
                if hargs ~= nil then v:handler(hargs) end
            end
        end,
        throw = function(self, deviceidx, method, ...)
            if self.catch and self.deviceidx = deviceidx then
                self:catch(deviceidx, method, unpack(arg))
            else self.parent:throw(deviceidx, method, unpack(arg)) end
        end,
        print = function(self) end,
        get = function(self) return self.value end,
        set = function(self, v) -----------------------~~~~~~~
            self.value = v
            self:action(v, self.meta)

            for i,v in ipairs(_.outputs) do
                self.roost:draw(v.deviceidx)
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

--[[
    setmetatable(self.inputs, {
        _index = function(t, k)
            return _.inputs[k]
        end,
        __newindex = function(t, k, v)
            if v.is_input then
                v.control = self
                v.deviceidx = self.deviceidx
                _.inputs[k] = v
            end
        end
    })

    setmetatable(self.outputs, {
        _index = function(t, k)
            return _.outputs[k]
        end,
        __newindex = function(t, k, v)
            if v.is_output then
                v.control = self
                v.deviceidx = self.deviceidx
                _.outputs[k] = v
            end
        end
    })

    -- i'm not sure if _.inputs, _.outputs need to be a thing, seems like a public member would  do the trick  ? ? ?

    setmetatable(_.inputs, {
        _index = function(t, k)
            return rawget(t,k)
        end,
        __newindex = function(t, k, v)
            if v.is_input then
                v.control = self
                v.deviceidx = self.deviceidx
                rawset(t,k,v)
            end
        end
    })

    setmetatable(_.outputs, {
        _index = function(t, k)
            return rawget(t,k)
        end,
        __newindex = function(t, k, v)
            if v.is_output then
                v.control = self
                v.deviceidx = self.deviceidx
                rawset(t,k,v)
            end
        end
    })
]]
    -- also maybe the above member metatables should go at the bottom & refer to o rather than self
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

    if o.inputs[1] == nil then o.inputs[1] = _input:new() end
    if o.outputs[1] == nil then o.outputs[1] = _output:new() end
    for i,v in ipairs(o.inputs) do
        v._.control = o
        v._.deviceidx = o._.deviceidx -- might not work :/
    end
    for i,v in ipairs(o.outputs) do
        v._.control = o
        v._.deviceidx = o._.deviceidx
    end

--[[
    _.inputs[1]._.control = self
    _.outputs[1]._.control = self
    _.inputs[1]._.deviceidx = self
    _.outputs[1]._.deviceidx = self
]]

    return o, _
end

-- pretty unsure if I'm doing this inheritence properly, feel like this needs to happen in the :new function

--[[
_metacontrol = _control:new()

_metacontrol.targets = {}
_metacontrol._.is_metacontrol = true
_metacontrol._.pass = function(self, control, value, meta) end

setmetatable(_metacontrol.targets, {
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

        table.insert(mt, _metacontrol)
        rawset(t,k,v)
    end
})

]]

_metacontrol = {
    targets = {} 
}
function _metacontrol:new(o)
    local _ = nil
    o, _ = _control:new(o)
    
    _.is_metacontrol = true
    _.pass = function(self, control, value, meta) end
    
    setmetatable(self.targets, {
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
        roost = function(self)
            if self._._meta == nil then self._._meta = {}
            self._._meta.roost = self  -- secret meta
            self:do_init()
        end,
        do_init = function(self)
            self:init()
            table.sort(self, function(a,b) return a.order < b.order end)

            for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
        end,
        connect = function(self, devices)
            self:roost()
            
            local m = self._._meta
            m.devies = devices
            setmetatable(m, m.devices)
            m.devices.__index = m.devices

                        
            local update = function()
                
            end

            for k,v in pairs(m.devices) do
            end
        end,
        init = function(self) end,
        each = function(self, cb) end,
        is_nest = true,
        index = nil,
        parent = nil,
        enabled = true,
        order = 0,
        metacontrols = {}, ----------------------------------rm
        metacontrols_enabled = true,
        update = function(self, deviceidx, args, metacontrols) -- rm metacontrols arg
            if self.metacontrols_enabled and metacontrols ~= nil then
                for i,v in ipairs(self.metacontrols) do table.insert(metacontrols, v) end
            else metacontrols = nil
            end

            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:update(deviceidx, args, metacontrols)
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
            v._.deviceidx = _.deviceidx
                        
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
