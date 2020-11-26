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

local function txtbox(txt, x, y, x2, y2, align, font, size, lvl, border, fill, padding, font_headroom, font_leftroom)
    local width = screen.text_extents(txt)
    local px = (type(padding) == 'table' and padding[1] or padding) * 2
    local py = (type(padding) == 'table' and padding[2] or padding) * 2

    screen.font_face(font)
    screen.font_size(size)

    local fixed = (x2 ~= nil) and (y2 ~= nil)
    local w, h, bx, by, tx, ty

    if fixed then
        -- fixed width, text centered in box
    else
        -- support align == 'left' or 'center' or 'right'

        w = width + px - 1
        h = size + py - 1 - (size * font_headroom)
        bx = x
        by = y
        tx = x - 1 + (px / 2) - (font == 1 and (size * font_leftroom) or 0)
        ty = y - 1 + (py / 2) + (size * (1 - font_headroom))
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
    screen.text(txt)
end

_txt.affordance.output.txtdraw = function(s, txt) 
    if type(txt) == 'table' then
        
    else
        local c = { x = { nil, nil }, y = { nil, nil } }
        for _,k in ipairs { 'x', 'y' } do 
            if type(s[k]) == 'table' then c[k] = s[k] 
            else c[k][1] = s[k] end    
        end

        txtbox(txt, c.x[1], c.y[1], c.x[2], c.y[2], s.align, s.font, s.size, s.lvl, s.border, s.fill, s.padding, s.font_headroom, s.font_leftroom)
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
