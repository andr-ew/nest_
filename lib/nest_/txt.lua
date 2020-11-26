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
    label = function(s) return s.k end
}

_txt.affordance.output.txt = function(s) end

local function txtbox(txt, x, y, align, font, size, lvl, border, fill, padding) 
    local width = screen.text_extents(txt)

    screen.font_face(font)
    screen.font_size(size)

    screen.level(fill)
    screen.rect(x, y, width + padding, 10)
    screen.fill()

    screen.level(border)
    screen.rect(x, y, width + padding, 10)
    screen.stroke()

    screen.level(lvl)
    screen.move(x + (padding / 2), y + 8)
    screen.text(txt)
end

_txt.affordance.output.txtdraw = function(s, txt) 
    txtbox(txt, s.x, s.y, s.align, s.font, s.size, s.lvl, s.border, s.fill, s.padding)    
end

_txt.affordance.output.redraw = function(s, ...) 
    screen.aa(s.aa)
    s:txtdraw(s:txt())
end

_txt.label = _txt.affordance:new {
    value = 'label'
} 

_txt.label.output.txt = function(s) return s.v end
