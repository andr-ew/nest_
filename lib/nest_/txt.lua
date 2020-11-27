_txt = _group:new()
_txt.devk = 'screen'

_txt.affordance = _screen.affordance:new {
    font = 1,
    size = 8,
    lvl = 15,
    border = 0,
    fill = 0,
    padding = 0,
    x = 1,
    y = 1,
    flow = 'x',
    align = 'left',
    wrap = nil,
    font_headroom = 3/8,
    font_leftroom = 1/16,
    label = function(s) return s.k end
}

_txt.affordance.output.txt = function(s) end

--[[

txt0d
txt1d
txt2d

]]

local function txtbox(txt, x, y, x2, y2, xalign, yalign, font, size, lvl, border, fill, padding, font_headroom, font_leftroom)
    font_headroom = font_headroom or 3/8 
    font_leftroom = font_leftroom or 1/16

    screen.font_face(font)
    screen.font_size(size)

    local fixed = (x2 ~= nil) and (y2 ~= nil)
    local width = screen.text_extents(txt)
    local height = size * (1 - font_headroom)
    local w, h, bx, by, tx, ty, tmode

    if fixed then
        w = x2 - x - 1
        h = y2 - y - 1

        bx = x
        by = y
        tx = bx + w/2 - 1
        ty = by + (h + height)/2 - 1
        tmode = 'center'
    else
        local px = (type(padding) == 'table' and padding[1] or padding) * 2
        local py = (type(padding) == 'table' and padding[2] or padding) * 2

        w = width + px - 1
        h = height + py - 1

        local bxalign = (xalign == 'center') and (((width + px) / 2) + 1) or (xalign == 'right') and (width + px) or 0
        local byalign = (yalign == 'center') and h/2 - 1 or (yalign == 'bottom') and h or 0
        local txalign = (xalign == 'center') and 0 or (xalign == 'right') and -1 or 1
        local tyalign = (yalign == 'center') and (height/2) or (yalign == 'bottom') and - (py/2) or height + (py/2) - 1

        bx = x - bxalign
        by = y - byalign
        tx = x - 1 + ((px / 2) * txalign) - (font == 1 and (size * font_leftroom) or 0)
        ty = y + tyalign
        tmode = xalign
    end

    if fill > 0 then
        screen.level(fill)
        screen.rect(bx - 1, by - 1, w + 1, h + 1)
        screen.fill()
    end

    if border > 0 then
        screen.level(border)
        screen.rect(bx, by, w, h)
        screen.stroke()
    end

    screen.level(lvl)
    screen.move(tx, ty)

    if tmode == 'right' then
        screen.text_right(txt)
    elseif tmode == 'center' then
        screen.text_center(txt)
    else
        screen.text(txt)
    end

    return w, h
end

function txtlist(txt, x, y, x2, y2, flow, wrap, margin, cellsize)
end

_txt.affordance.output.txtdraw = function(s, txt) 
    if type(txt) == 'table' then
                
    else
        local c = { x = { nil, nil }, y = { nil, nil }, align = { 'left', 'top' } }
        for _,k in ipairs { 'x', 'y', 'align' } do 
            if type(s[k]) == 'table' then c[k] = s[k] 
            else c[k][1] = s[k] end    
        end
            
        txtbox(txt, c.x[1], c.y[1], c.x[2], c.y[2], c.align[1], c.align[2], s.font, s.size, s.lvl, s.border, s.fill, s.padding, s.font_headroom, s.font_leftroom)
    end
end

_txt.affordance.output.redraw = function(s, ...) 
    screen.aa(s.aa)
    s:txtdraw(s:txt())
end

_txt.label = _txt.affordance:new {
    value = 'label'
} 

_txt.label.output.txt = function(s) return s.v end
