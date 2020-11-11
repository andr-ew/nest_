--include 'lib/nest_/core'

nest_.connect = function(self, objects, fps)
    self:do_init()

    local devs = {}

    local fps = fps or 30
    local elapsed = 0

    -- elapsed // 3 % 2

    for k,v in pairs(objects) do
        if k == 'g' or k == 'a' then
            local kk = k
            local vv = v
            
            devs[kk] = _dev:new {
                object = vv,
                redraw = function() 
                    vv:all(0)
                    self:draw(kk, elapsed) 
                    vv:refresh()
                end,
                handler = function(...)
                    self:update(kk, {...}, {})
                end
            }

            v[(kk == 'g') and 'key' or 'delta'] = devs[kk].handler
        elseif k == 'm' or k == 'h' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                object = vv,
                handler = function(data)
                    self:update(kk, data, {})
                end
            }

            v.event = devs[kk].handler
        elseif k == 'enc' or k == 'key' then
            local kk = k
            local vv = v

            devs[kk] = _dev:new {
                handler = function(...)
                    self:update(kk, {...}, {})
                end
            }

            v = devs[kk].handler
        elseif k == 'screen' then
            devs[kk] = _dev:new {
                object = screen,
                redraw = function()
                    screen.clear()
                    self:draw('screen', elapsed)
                    screen.update()
                end
            }
            
            redraw = devs[kk].redraw
        else 
            print('nest_.connect: invalid device key. valid options are g, a, m, h, screen, enc, key')
        end
    end

    clock.run(function() 
        while true do 
            clock.sleep(1/fps)
            elapsed = elapsed + 1/fps
            
            for k,v in pairs(devs) do 
                if v.dirty then 
                    v.dirty = false
                    v.redraw()
                end

                --v.animate(elapsed)
            end
        end   
    end)

    local function linkdevs(obj) 
        if type(obj) == 'table' and obj.is_obj then
            rawset(obj._, 'devs', devs)
            
            --might not be needed with _output.redraw args
            for k,v in pairs(objects) do 
                rawset(obj._, k, v)
            end
            
            for k,v in pairs(obj) do 
                linkdevs(v)
            end
        end
    end

    linkdevs(self)
    
    return self
end

_enc = _group:new()
_enc.devk = 'enc'

_enc.control = _control:new { n = 1 }
