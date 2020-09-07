wrms = {}

wrms.lfo = include 'wrms/lib/hnds_wrms'
supercut = include 'wrms/lib/supercut'
controlspec = require 'controlspec'


--[[

i must say things aren't quite too tidy over here :/

fotunately - most of this shouldn't need to be modified. many things can happen within the existing architecture for pages 
without any additional modification to the user interface code here !

]]---

---------------------------------------------- utility functions --------------------------------------------------------------------

function wrms.page_from_label(label)
  for i,v in ipairs(wrms.pages) do
    if(v.label == label) then return v end
  end
end

function wrms.update_control(control, val, t, from_param) -- you probably only need to worry about sending 1st 2 args, control and value. if value is absent it will just update the control
  if val ~= nil then control.value = val end
  if t == nil then t = 0 end
  if control.event == nil then
    print("update_control: invalid control")
    return
  end
  
  control:event(control.value, t)
  
  if (from_param == nil or from_param == false) and control.behavior ~= "toggle" and control.behavior ~= "momentary" then
    local id = ((control.behavior == "enum") and control.label[1] or control.label) .. " " .. tostring(control.worm)
    params:set(id, control.value, true)
  end
end

--------------------------------------------------------------------------------------------------------------------------------------

wrms.sens = 0.01

wrms.pages = {}

wrms.page_n = 1
local get_page_n = function() return math.floor(wrms.page_n) end

supercut.add_data("is_punch_in", false)
supercut.add_data("has_initial", false)
supercut.add_data("wiggle", 0)
supercut.add_data("feed", 0)
supercut.has_initial(1, true)
supercut.feed(1, 1)

-- for putting wrms to sleep zZzz :)
local function awake_seg()
  ret = {}
  
  for i = 1, 24 do
    ret[i] = false
  end
  
  return ret
end

supercut.add_data("segment_is_awake", awake_seg)
supercut.add_data("sleep_index", 24)

function wrms.wake(voice)
  supercut.sleep_index(voice, 24)
end

wrms.sleep = wrms.wake

local function sleep_iter()
  for i = 1,2 do
    if supercut.sleep_index(i) > 0 and supercut.sleep_index(i) <= 24 then
      supercut.segment_is_awake(i)[math.floor(supercut.sleep_index(i))] = supercut.has_initial(i)
      supercut.sleep_index(i, supercut.sleep_index(i) + (0.5 * (supercut.has_initial(i) and -1 or -2)))
    end
  end
end

local sleep_metro = metro.init(sleep_iter, 1/150)

function wrms.page_params()
  
  -- generate params
  
  local actions = { 
    number = function(control)
      return function(v)
        wrms.update_control(control, v, 0, true)
      end
    end,
    momentary = function(control)
      return function(v)
        wrms.update_control(control, 0, 0, true) 
      end
    end,
    toggle = function(control)
      return function(v)
        wrms.update_control(control, control.value == 0 and 1 or 0, 0, true)
      end
    end,
    enum = function(control)
      return function(v)
        wrms.update_control(control, v, 0, true)
      end
    end
  }
  
  for i,v in ipairs(wrms.pages) do
    for j,w in ipairs({ v.e2, v.e3 }) do
      if w ~= nil then 
        local id = w.label .. " " .. tostring(w.worm)
        
        params:add_control(id, id, controlspec.new(w.range[1], w.range[2], 'lin', w.sens or wrms.sens, w.value, ''))
        params:set_action(id, actions.number(w))
      end
    end
    for j,w in ipairs({ v.k2, v.k3 }) do
      if w ~= nil then 
        
        local id = ((w.behavior == "enum") and w.label[1] or w.label) .. " " .. tostring(w.worm)
        
        local pp = {
          type = (w.behavior == "enum") and "option" or "trigger",
          id = id,
          action = actions[w.behavior](w)
        }
        
        if w.behavior == "enum" then
          pp.default = w.value
          pp.options = w.label
        end
        
        params:add(pp)
      end
    end
  end
end

function wrms.pages_init()
  for i,v in ipairs(wrms.pages) do
    for k,w in pairs(v) do
      if type(w) == "table" and w.behavior ~= "momentary" then 
        wrms.update_control(w, w.value, 0, true)
      end
    end
  end
  
  sleep_metro:start()
end

function wrms.enc(n, delta)
  if n == 1 then wrms.page_n = util.clamp(wrms.page_n + (util.clamp(delta, -1, 1) * 0.25), 1, #wrms.pages)
  else
    local e = wrms.pages[get_page_n()]["e" .. n]
    
    if e ~= nil then
      local sens = e.sens == nil and wrms.sens or e.sens
      wrms.update_control(e, util.round(util.clamp(e.value + (delta * sens), e.range[1], e.range[2]), sens))
    end
  end
end

local combo_down = false

function wrms.key(n,z)
  if n == 1 then
    rec = z
  else
    local k = wrms.pages[get_page_n()]["k" .. n]
    
    if k ~= nil then
      local other = wrms.pages[get_page_n()]["k" .. ((n == 2) and 3 or 2)]
      local k2_k3 = wrms.pages[get_page_n()]["k2_k3"]
      
      if z == 1 then
        k.time = util.time()
        if k.behavior == "momentary" then 
          k.value = 1
          
          if k2_k3 ~= nil and other.value == 1 then
            combo_down = true
          end
        end
      else
        if k.behavior == "momentary" then k.value = 0
        elseif k.behavior == "toggle" then k.value = k.value == 0 and 1 or 0
        elseif k.behavior == "enum" then k.value = k.value == #k.label and 1 or k.value + 1 end
        
        if k2_k3 ~= nil and combo_down then
          if k.value == 0 and other.value == 0 then
            combo_down = false
            
            k2_k3:event(nil, util.time() - k.time)
          end
        else
          wrms.update_control(k, k.value, util.time() - k.time)
          k.time = nil
        end
      end
    end
  end
end


wrms.draw = {}

wrms.draw.pager = function()
  for i,v in ipairs(wrms.pages) do
    screen.move(128 - 4, i * 7)
    screen.level(get_page_n() == i and 8 or 2)
    screen.text_center(v.label)
  end
end

local function get_x_pos(c1, c2)
  local ret, wrm1, wrm2
  
  if c1 == nil then wrm1 = 1 else wrm1 = c1.worm end
  if c2 == nil then wrm2 = 2 else wrm2 = c2.worm end
  
  if wrm1 == 1 and wrm2 == 2 then ret = { 0, 2 }
  elseif wrm1 == 1 and wrm2 == 1 then ret = { 0, 1 }
  elseif wrm1 == 2 and wrm2 == 2 then ret = { 2, 3 }
  elseif wrm1 == "both" and wrm2 == 2 then ret = { 1.5, 3 }
  elseif wrm1 == 1 and wrm2 == "both" then ret = { 0, 1.5 }
  else ret = { 2, 0 } end
  
  return ret
end

wrms.draw.enc = function()
  local ex = get_x_pos(wrms.pages[get_page_n()].e2, wrms.pages[get_page_n()].e3)
  for i,v in ipairs({ wrms.pages[get_page_n()].e2, wrms.pages[get_page_n()].e3 }) do
    if v ~= nil then
      screen.move(2 + ex[i] * 29, 46)
      screen.level(4)
      screen.text(v.label)
      screen.move(2 + (ex[i] * 29) + ((string.len(v.label) + 0.5) * 5), 46)
      screen.level(10)
      screen.text(v.value)
    end
  end
end

wrms.draw.key = function()
  local kx = get_x_pos(wrms.pages[get_page_n()].k2, wrms.pages[get_page_n()].k3)
  for i,v in ipairs({ wrms.pages[get_page_n()].k2, wrms.pages[get_page_n()].k3 }) do
    if v ~= nil then
      screen.move(2 + kx[i] * 29, 46 + 10)
      
      if v.behavior == "enum" then
        screen.level(8)
        screen.text(v.label[math.floor(v.value)])
      else
        screen.level(v.value * 10 + 2)
        screen.text(v.label)
      end
    end
  end
end

wrms.draw.animations = function()
  
  --feed indicators
  screen.level(math.floor(supercut.feed(1) * 4))
  screen.pixel(42, 23)
  screen.pixel(43, 24)
  screen.pixel(42, 25)
  screen.fill()
  
  screen.level(math.floor(supercut.feed(2) * 4))
  screen.pixel(54, 23)
  screen.pixel(53, 24)
  screen.pixel(54, 25)
  screen.fill()
  
  for i = 1,2 do
    
    local left = 2 + (i-1) * 58
    local top = 34
    local width = 44
    
    --phase
    screen.level(2)
    if supercut.is_punch_in(i) == false then
      screen.pixel(left + width * supercut.loop_start(i) / supercut.region_length(i), top) --loop start
      screen.fill()
    end
    if supercut.has_initial(i) then
      screen.pixel(left + width * supercut.loop_end(i) / supercut.region_length(i), top) --loop end
      screen.fill()
    end
    
    screen.level(6 + 10 * supercut.rec(i))
    if supercut.has_initial(i) == false then -- rec line
      if supercut.is_punch_in(i) then
        screen.move(left + width * util.clamp(0, 1, supercut.loop_start(i) / supercut.region_length(i)), top + 1)
        screen.line(1 + left + width * math.abs(util.clamp(0, 1, supercut.region_position(i) / supercut.region_length(i))), top + 1)
        screen.stroke()
      end
    else
      screen.pixel(left + width * supercut.region_position(i) / supercut.region_length(i), top) -- loop point
      screen.fill()
    end
    
    --fun wrm animaions
    local top = 18
    local width = 24
    local lowamp = 0.5
    local highamp = 1.75
    
    
    
    screen.level(math.floor(supercut.level(i) * 10))
    local width = util.linexp(0, (supercut.region_length(i)), 0.01, width, (supercut.loop_length(i)  + 4.125))
    for j = 1, width do
      local amp = supercut.segment_is_awake(i)[j] and math.sin(((supercut.position(i) - supercut.loop_start(i)) * (i == 1 and 1 or 2) / (supercut.loop_end(i) - supercut.loop_start(i)) + j / width) * (i == 1 and 2 or 4) * math.pi) * util.linlin(1, width / 2, lowamp, highamp + supercut.wiggle(i), j < (width / 2) and j or width - j) - 0.75 * util.linlin(1, width / 2, lowamp, highamp + supercut.wiggle(i), j < (width / 2) and j or width - j) - (util.linexp(0, 1, 0.5, 6, j/width) * (supercut.rate2(i) - 1)) or 0      
      local left = left - (supercut.loop_start(i)) / (supercut.region_length(i)) * (width - 44)
    
      screen.pixel(left - 1 + j, top + amp)
    end
    screen.fill()
    
  end
end


function wrms.redraw()
  screen.clear()
  
  wrms.draw.pager()
  wrms.draw.enc()
  wrms.draw.key()
  wrms.draw.animations()
  
  screen.update()
end

wrms.cleanup = function()
  params:write()
end

function wrms.params()
  local function in_closure(vc, inn, chan) return function(v) supercut.level_input_cut(inn, vc, v, chan) end end
  local function pan_closure(vc) return function(v) supercut.pan(vc, v) end end
  
  for i = 1,2 do
    params:add_control("in L > wrm " .. i .. "  L", "in L > wrm " .. i .. "  L", controlspec.new(0,1,'lin',0,1,''))
    params:set_action("in L > wrm " .. i .. "  L", in_closure(i, 1, 1))
    params:add_control("in L > wrm " .. i .. "  R", "in L > wrm " .. i .. "  R", controlspec.new(0,1,'lin',0,0,''))
    params:set_action("in L > wrm " .. i .. "  R", in_closure(i, 1, 2))
    params:add_control("in R > wrm " .. i .. "  R", "in R > wrm " .. i .. "  R", controlspec.new(0,1,'lin',0,1,''))
    params:set_action("in R > wrm " .. i .. "  R", in_closure(i, 2, 2))
    params:add_control("in R > wrm " .. i .. "  L", "in R > wrm " .. i .. "  L", controlspec.new(0,1,'lin',0,0,''))
    params:set_action("in R > wrm " .. i .. "  L", in_closure(i, 2, 1))
    
    params:add_control("wrm " .. i .. " pan", "wrm " .. i .. " pan", controlspec.PAN)
    params:set_action("wrm " .. i .. " pan", pan_closure(i))
  end
  
  params:add_separator()
  
  params:add_file("wrm 1 load", "wrm 1 load")
  params:set_action("wrm 1 load", function(file)
    supercut.buffer_read(file, 1)
    wrms.update_control(wrms.page_from_label("v").k2, 0)
  end)
  -- params:add{ type = "trigger", id = "wrm 1 save", name = "wrm 1 save", action = function() supercut.buffer_write(_path.dust.."/audio/wrms_"..os.date("%y%m%d_%X") ..".wav", 1) end }
  
  params:add_file("wrm 2 load", "wrm 2 load")
  params:set_action("wrm 2 load", function(file)
    supercut.buffer_read(file, 2)
    wrms.update_control(wrms.page_from_label("v").k3, 0)
  end)
  -- params:add{ type = "trigger", id = "wrm 2 save", name = "wrm 2 save", action = function() supercut.buffer_write(_path.dust.."/audio/wrms_"..os.date("%y%m%d_%X") ..".wav", 2) end }
end

wrms.init = function()
  wrms.sc_init()
  wrms.lfo.init()
  wrms.params()
  params:add_separator()
  wrms.page_params()
  params:read()
  for i = 1,2 do
    params:set("wrm "..i.." load", "-")
  end
  supercut.buffer_clear()
  params:bang()
  wrms.pages_init()
end

return wrms