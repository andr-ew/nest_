--[[

per the phase-out of _meta, this function will simply add the devices table to every _input or _output in the nest

_dev = _obj_:new {
    dirty = true,
    object = nil,
    redraw = nil,
    handler = nil
}

]]

include 'lib/nest_/core.lua'

nest_.connect = function(self, objects)
    self:do_init()

    local devs = {}

    for k,v in pairs(objects) do
        if k == 'g' or k == 'a' then
            local kk = k
            local vv = v
            
            devs[kk] = _dev:new {
                object = vv,
                redraw = function() 
                    vv:all(0)
                    self:draw(kk) 
                    vv:refresh()
                end,
                handler = function(...)
                    self:update(kk, {...})
                end
            }

            v[(kk == 'g') and 'key' or 'delta'] = devs[kk].handler
        elseif k == 'm' or k == 'h' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                object = vv,
                handler = function(data)
                    self:update(kk, data)
                end
            }

            v.event = devs[kk].handler
        elseif k == 'enc' or k == 'key' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                handler = function(...)
                    self:update(kk, {...})
                end
            }

            v = devs[kk].handler
        elseif k == 'screen' then
            devs[kk] = _dev:new {
                redraw = function()
                    screen.clear()
                    self:draw('screen')
                    screen.update()
                end
            }
            
            redraw = devs[kk].redraw
        else 
            print('nest_.connect: invalid device key. valid options are g, a, m, h, screen, enc, key')
        end
    end

    -- initialize tick clock in devs, start clock

    -- add devs, objects memebers to every decendent in self
    
    return self
end

-- create screen, enc, key _devices
