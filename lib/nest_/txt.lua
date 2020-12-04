_txt = _group:new()
_txt.devk = 'screen'

_txt.affordance = _screen.affordance:new {
    font = 1,
    size = 8,
    lvl = 15,
    border = 0,
    fill = 0,
    padding = 0,
    margin = 0,
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

local function txtpoint(txt, a)
    -- x, y, align font, size, lvl, border, fill, padding, font_headroom, font_leftroom

    local d = { 
        x = { nil, nil }, 
        y = { nil, nil },
        align = { 'left', 'top' } 
    }

    for _,k in ipairs { 'x', 'y', 'align' } do 
        if type(a[k]) == 'table' then d[k] = a[k] 
        else d[k][1] = a[k] end    
    end

    screen.font_face(a.font)
    screen.font_size(a.size)

    local fixed = (d.x[2] ~= nil) and (d.y[2] ~= nil)
    local width = screen.text_extents(txt)
    local height = a.size * (1 - a.font_headroom)
    local w, h, bx, by, tx, ty, tmode

    if fixed then
        w = d.x[2] - d.x[1] - 1
        h = d.y[2] - d.y[1] - 1

        bx = d.x[1]
        by = d.y[1]
        tx = bx + w/2 - 1
        ty = by + (h + height)/2 - 1
        tmode = 'center'
    else
        local px = (type(a.padding) == 'table' and a.padding[1] or a.padding or 0) * 2
        local py = (type(a.padding) == 'table' and a.padding[2] or a.padding or 0) * 2

        w = width + px - 1
        h = height + py - 1

        local xalign = d.align[1]
        local yalign = d.align[2]
        local bxalign = (xalign == 'center') and (((width + px) / 2) + 1) or (xalign == 'right') and (width + px) or 0
        local byalign = (yalign == 'center') and h/2 - 1 or (yalign == 'bottom') and h or 0
        local txalign = (xalign == 'center') and 0 or (xalign == 'right') and -1 or 1
        local tyalign = (yalign == 'center') and (height/2) or (yalign == 'bottom') and - (py/2) or height + (py/2) - 1

        bx = d.x[1] - bxalign
        by = d.y[1] - byalign
        tx = d.x[1] - 1 + ((px / 2) * txalign) - (a.font == 1 and (a.size * a.font_leftroom) or 0)
        ty = d.y[1] + tyalign
        tmode = xalign
    end

    if a.fill > 0 then
        screen.level(a.fill)
        screen.rect(bx - 1, by - 1, w + 1, h + 1)
        screen.fill()
    end

    if a.border > 0 then
        screen.level(a.border)
        screen.rect(bx, by, w, h)
        screen.stroke()
    end

    screen.level(a.lvl)
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

function txtpoint_extents(txt, a) 
    local d = { 
        x = { nil, nil }, 
        y = { nil, nil }
    }
    
    local width = screen.text_extents(txt)
    local height = a.size * (1 - a.font_headroom)
    local w, h

    for _,k in ipairs { 'x', 'y' } do 
        if type(a[k]) == 'table' then d[k] = a[k] 
        else d[k][1] = a[k] end    
    end
    
    local fixed = (d.x[2] ~= nil) and (d.y[2] ~= nil)

    if fixed then
        w = d.x[2] - d.x[1] - 1
        h = d.y[2] - d.y[1] - 1
    else
        local px = (type(a.padding) == 'table' and a.padding[1] or a.padding or 0) * 2
        local py = (type(a.padding) == 'table' and a.padding[2] or a.padding or 0) * 2

        w = width + px - 1
        h = height + py - 1
    end
    local function setetc(pa, i) 
        for j,k in ipairs { 'font', 'size', 'lvl', 'border', 'fill', 'font_headroom', 'font_leftroom' } do 
            local w = a[k]
            pa[k] = (type(w) == 'table') and w[i] or w
        end

        pa.padding = a.padding
    end

    local function setax(pa, xy)
        for j,k in ipairs(ax) do
            if a.cellsize then
                pa[k] = { xy[k], iax[k] + cellsize[j] }
            else 
                pa[k] = { xy[k] }
            end
        end
    end

    return w, h
end

local function placeaxis(txt, mode, iax, lax, place, extents, a)
    --align, margin, flow, cellsize


    local flow = a.flow
    local noflow
    local margin = (type(a.margin) == 'table') and { x = a.margin[1], y = a.margin[2] } or { x = a.margin, y = a.margin }
    local start, justify, manual = 1, 2, 3
    local ax = { 'x', 'y' }
    local xalign = (type(a.align) == 'table') and a.align[1] or a.align
    local yalign = (type(a.align) == 'table') and a.align[2] or 'top'
    local align = { x = xalign, y = yalign }
    local dimt = { x = 0, y = 0 }
    local initax = {}

    for i,k in ipairs(ax) do if k ~= flow then noflow = k end end
    for i,k in ipairs(ax) do initax[k] = iax[k] end

    local function setetc(pa, i) 
        for j,k in ipairs { 'font', 'size', 'lvl', 'border', 'fill', 'font_headroom', 'font_leftroom' } do 
            local w = a[k]
            pa[k] = (type(w) == 'table') and w[i] or w
        end

        pa.padding = a.padding
    end

    local function setax(pa, xy)
        for j,k in ipairs(ax) do
            if a.cellsize and type(a.cellsize) == 'table' then
                pa[k] = { xy[k], iax[k] + cellsize[j] }
            else 
                pa[k] = xy[k]
            end
        end
    end

    if mode == start then
        local j = 1

        local dir, st, en
        if align[flow] == 'left' or 'top' then
            dir = 1
            st = 1
            en = #txt
        else
            dir = -1
            st = #txt
            en = 1
        end
        
        local dim
        for i = st, en, dir do 
            local v = txt[i]
            local pa = {}
            dim = {} 

            setetc(pa, i)
            setax(pa, iax)
            pa.align = a.align

            dim.x, dim.y = place(v, pa)

            iax[flow] = iax[flow] + ((dim[flow] + margin[flow] + 1) * dir)
            
            if a.wrap and j >= a.wrap then
                j = 1
                iax[flow] = a[flow]
                iax[noflow] = iax[noflow] + dim[noflow] + margin[noflow] + 1
            end

            j = j + 1
        end

        for i,k in ipairs(ax) do
            dimt[k] = (iax[k] + ((dim[k] + 1) * dir)) - initax[k]
        end
    elseif mode == justify then
        local ex = {}
        local exsum = { x = 0, y = 0 }
        do
            local pa = {}
            setetc(pa, 1)
            setax(pa, iax)
            pa.align = (flow == 'x') and { 'left', yalign } or { xalign, 'top' }

            ex[1] = {}
            ex[1].x, ex[1].y = place(txt[1], pa)
            exsum[flow] = exsum[flow] + ex[1][flow] + 1
        end
        do
            local pa = {}
            setetc(pa, #txt)
            setax(pa, lax)
            pa.align = (flow == 'x') and { 'right', yalign } or { xalign, 'bottom' }

            ex[#txt] = {}
            ex[#txt].x, ex[#txt].y = place(txt[#txt], pa)
            exsum[flow] = exsum[flow] + ex[#txt][flow] + 1
        end

        local pa_btw = {}
        
        for i = 2, #txt - 1, 1 do
            pa_btw[i] = {}
            setetc(pa_btw[i], i)
            setax(pa_btw[i], iax)

            ex[i] = {}
            ex[i].x, ex[i].y = extents(txt[i], pa_btw[i])
            exsum[flow] = exsum[flow] + ex[i][flow] + 1
        end

        for i,v in ipairs(ex) do 
            exsum[noflow] = math.max(exsum[noflow], v[noflow])
        end

        local margin = ((lax[flow] - iax[flow]) - exsum[flow]) / (#txt - 1)

        for i = 2, #txt - 1, 1 do
            iax[flow] = iax[flow] + ex[i - 1][flow] + margin + 1
            
            setax(pa_btw[i], iax)
            pa_btw[i].align = (flow == 'x') and { 'left', yalign } or { xalign, 'top' }
            place(txt[i], pa_btw[i])
        end

        dimt[flow] = a[flow][2] - a[flow][1]
        dimt[noflow] = exsum[noflow]

    elseif mode == manual then
        for i,v in ipairs(txt) do 
            local pa = {}   
            setetc(pa, i)
            
            for j,k in ipairs(ax) do 
                if flow == nil or flow == k then pa[k] = a[k][i]
                else pa[k] = a[k] end
            end

            place(v, pa)
        end
    end
    
    return dimt.x, dimt.y
end

local function txtline(txt, a)
    --x, y, align, flow, wrap, margin, cellsize

    local ax = { 'x', 'y' }
    local start, justify, manual = 1, 2, 3
    local mode = start
    local iax = {}
    local lax = {}  

    for i,k in ipairs(ax) do
        if type(a[k]) == 'table' then
            if type(a[k][1]) ~= 'table' then
                if mode == start then
                    mode = justify
                    flow = k
                    iax[k] = a[k][1]
                    lax[k] = a[k][2]
                end
            else
                if mode == manual then
                    flow = nil
                else
                    mode = manual
                    flow = k
                end
            end
        else
            iax[k] = a[k]
            lax[k] = a[k]
        end
    end

    return placeaxis(txt, mode, iax, lax, 
        function(v, a) 
            return txtpoint(v, a)
        end, 
        function(v, a) 
            return txtpoint_extents(v, a)
        end, 
        a
    )
end

local function txtplane(txt, a)
    --x, y, align, flow, wrap, margin, cellsize

    local start, justify, manual = 1, 2, 3
    local mode = { x = start, y = start }
    local iax = {}
    local lax = {}  
    local ax = { 'x', 'y' }
    
    local flow = a.flow
    local noflow
    for i,k in ipairs(ax) do if k ~= a.flow then noflow = k end end
    
    for i,k in ipairs(ax) do
        if type(a[k]) == 'table' then
            if type(a[k][1]) ~= 'table' then
                mode[k] = justify
                iax[k] = a[k][1]
                lax[k] = a[k][2]
            else
                mode[k] = manual
            end
        else
            iax[k] = a[k]
            lax[k] = a[k]
        end
    end
    
    local function cb(extents) 
        return function(v, b) 
            setmetatable(b, { __index = a })
            
            liax = {}
            llax = {}
            b.flow = noflow
            b[noflow] = a[noflow]

            liax[flow] = b[flow]
            liax[noflow] = iax[noflow]
            llax[flow] = b[flow]
            llax[noflow] = lax[noflow]

            return placeaxis(v, mode[noflow], liax, llax, 
                function(w, a) 
                    if extents then
                        return txtpoint_extents(w, a)
                    else
                        return txtpoint(w, a)
                    end
                end, 
                function(w, a) 
                    return txtpoint_extents(w, a)
                end, 
                b
            )
        end
    end

    local b = {}
    setmetatable(b, { __index = a })
    
    --b.cellsize = ""

    return placeaxis(txt, mode[a.flow], iax, lax, cb(false), cb(true), b)
end

_txt.affordance.output.txtdraw = function(s, txt) 
    if type(txt) == 'table' then

        local plane = false
        for i,v in ipairs(txt) do
            if type(v) == 'table' then
                plane = true
            end 
        end

        if plane then
            txtplane(txt, s.p_)                
        else
            txtline(txt, s.p_)                
        end
    else
        txtpoint(txt, s.p_)   
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
