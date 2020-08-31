_input = {}
function _input:new(o)
    local _ = {
        is_input = true,
        control = nil,
        groupidx = nil, ---> group, add deviceidx

        --[[
        
        deviceidx must me a key from self.devices, defined on an elder

        ]]

        transform = function(v) return v end,
        handler = function(self, ...) return false end,
        check = function(self, groupidx, args) ---> update
            if(self._.groupidx == groupidx) then

            --[[

            here, to support multi-device groups like _grid & _arc (no more _grid1, grid2, ...) we'll need to pass down a deviceidx (index of group.device) & compare w/ self.deviceidx rather than self.groupidx

            ]]

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
        groupidx = nil,  ---> group, add deviceidx

        --[[
        
        deviceidx must me a key from self.devices, defined on an elder

        ]]

        transform = function(v) return v end,
        handler = function(self) return false end, --> redraw
        draw = function(self, ...) --> throw (?)
            self._.control._.draw(self._.control, self.groupidx, unpack(arg))

            --[[

            lets say that the handler is welcome to perform draw actions straight on the device in a familiar style ( s.screen.text() ).

            to allow a nest of controls to be reassigned to a different Grid or Arc objects on seprate vports, we'll establish the convention of placing something like:

                _meta = {
                    devices = {
                        grid = { Grid.vport }
                        arc = { Arc.vport }
                        screen = screen,
                        g = devices.grid[1],
                        a = devices.grid[2]
                    },
                    grid = devices.grid,
                    arc = devies.arc,
                    screen = screen,
                    g = devices.grid[1],
                    a = devices.arc[1]
                }

            on the parent nest or nest relevant to a particular device. in the handler, you can access the intended device like this: s.g:led()

            the _meta assignment could be astracted as: nest_:connect(grid.connect(), arc.connect(), screen). this also defines the device handlers to call :update_draw(deviceidx) or :draw() (fka check, look) on this nest 

            in special cases, this function here can be used to 'throw' args up to an elder nest. this nest would have a 'catch()' defined that takes those args & draws to a device (useful for screen UIs, probably other things)

            ]]

        end,
        look = function(self, groupidx) --> draw
            if(self._.groupidx == groupidx) then  ---> group, add deviceidx.deviceidx == deviceidx
                self:handler() --> redraw
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
        elseif _[k] ~= nil then return _[k]
        elseif _.control[k] ~= nil then return _.control[k]
        else return rawget(self, k) end
    end
    return o
end

_control = {
    value = 0,
    event = function(s, v) end, ---> action
    order = 0,
    enabled = true,
    init = function(s) end,
    inputs = {},
    outputs = {},
    help = function(s) end
}

function _control:new(o)
    local _ = {
        inputs = {},
        outputs = {},
        is_control = true,
        index = nil,
        parent = self,
        do_init = function(self)
            self:init()
        end,
        groupidx = nil,  ---> group, add deviceidx
        metacontrols = {},
        metacontrols_enabled = true,
        check = function(self, groupidx, args, metacontrols)  ---> group, add deviceidx
            for i,v in ipairs(_.inputs) do
                local hargs = v:check(groupidx, args)  ---> group, add deviceidx

                if hargs ~= nil then
                    for i,v in ipairs(metacontrols) do
                        v:pass(hargs)
                    end

                    v:handler(hargs)

                    for i,v in ipairs(_.outputs) do
                        nest_api.groups[v.groupidx]:look()  ---> group, add deviceidx
                    end
                end
            end
        end,
        look = function(self, groupidx) --> draw
            for i,v in ipairs(_.outputs) do
                local hargs = v:look(groupidx)
                if hargs ~= nil then v:handler(hargs) end
            end
        end,
        draw = function(self, groupidx, method, ...)  ---> throw
            self.parent:draw(groupidx, method, unpack(arg))
        end,
        print = function(self) end,
        get = function(self) return self.value end,
        set = function(self, v) -----------------------~~~~~~~
            self.value = v
            self:event(v, self.meta)

            for i,v in ipairs(_.outputs) do
                nest_api.groups[v.groupidx]:look()  ---> group, add deviceidx
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

    setmetatable(self.inputs, {
        _index = function(t, k)
            return _.inputs[k]
        end,
        __newindex = function(t, k, v)
            if v.is_input then
                v.control = self
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
                _.outputs[k] = v
            end
        end
    })

    setmetatable(_.inputs, {
        _index = function(t, k)
            return rawget(t,k)
        end,
        __newindex = function(t, k, v)
            if v.is_input then
                v.control = self
                v.groupidx = self.groupidx
                rawset(t,k,v)
            end
        end
    })

    setmetatable(_.outputs, {
        _index = function(t, k)
            return _.outputs[k]
        end,
        __newindex = function(t, k, v)
            if v.is_output then
                v.control = self
                v.groupidx = self.groupidx
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
        elseif k == "input" then return t.inputs[1]
        elseif k == "output" then return t.outputs[1]
        elseif k == "target" then return t.targets[1]
        elseif _[k] ~= nil then return _[k]
        elseif findmeta(_.parent) ~= nil then return findmeta(_.parent)
        else return rawget(self, k) end
    end

    _.inputs[1] = _input:new()
    _.outputs[1] = _output:new()

    _.inputs[1]._.control = self
    _.outputs[1]._.control = self

    _.inputs[1]._.groupidx = _.groupidx
    _.outputs[1]._.groupidx = _.groupidx

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
            table.sort(self, function(a,b) return a.order < b.order end)

            for k,v in pairs(self) do if v.is_nest or v.is_control then v:do_init() end end
        end,
        init = function(self) end,
        each = function(slef, cb) end,
        is_nest = true,
        index = nil,
        parent = nil,
        enabled = true,
        order = 0,
        groupidx = nil, ---> group, add deviceidx
        metacontrols = {},
        metacontrols_enabled = true,
        check = function(self, groupidx, args, metacontrols)  ---> group, add deviceidx
            if self.metacontrols_enabled and metacontrols ~= nil then
                for i,v in ipairs(self.metacontrols) do table.insert(metacontrols, v) end
            else metacontrols = nil
            end

            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:check(groupidx, args, metacontrols)  ---> group, add deviceidx
            end end
        end,
        look = function(self, groupidx)  ---> group, add deviceidx, -> draw
            for k,v in pairs(self) do if v.is_nest or v.is_control then
                v:look(groupidx)
            end end
        end,
        draw = function(self, groupidx, method, ...) ---> group, add deviceidx, -> throw

            --rm
            if self.is_roost then
                nest_api.groups[groupidx]:draw(method, unpack(arg))  ---> group, add deviceidx
            else
            -- /rm
                self.parent:draw(groupidx, method, unpack(arg))  ---> group, add deviceidx
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
        is_group = true,
        init = function(self) nest_api:look(self.index) end,
        check = function(self, args)
            nest_api.roost:check(self.index, args, {})
        end,
        look = function(self) end, --> draw
        draw = function(self, method, ...) end -- rm
        -- add devices = {}
        -- add group (!) for nesting fun
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
        if type(v) == "table" and v._ ~= nil then
            v._.group = t
            rawset(t,k,v)
        end
    end

    return o
end

nest_api = {
    init = function(self)
        for k,v in pairs(self.groups) do v:init() end
        self.roost:do_init()
    end,
    groups = {}
}

setmetatable(nest_api.groups, {
    __newindex = function(t, k, v)
--        v._.index = k -- metatable issue ?
        _G[k] = v

        rawset(t,k,v)
    end
})
