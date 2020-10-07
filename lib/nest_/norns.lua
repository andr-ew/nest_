--[[

per the phase-out of _meta, this function will simply add the devices table to every _input or _output in the nest

]]

include 'lib/nest_/core.lua'

nest_.connect = function(self, devices)
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
end
