local function txtpoint(txt, a, extents)
    -- x, y, size, align, font_face, font_size, lvl, border, fill, padding, font_headroom, font_leftroom

    local d = { 
        x = { nil, nil }, 
        y = { nil, nil },
        align = { 'left', 'top' } 
    }

    for _,k in ipairs { 'x', 'y', 'align' } do 
        if type(a[k]) == 'table' then d[k] = a[k] 
        else d[k][1] = a[k] end    
    end

    screen.font_face(a.font_face)
    screen.font_size(a.font_size)

    local ax = { 'x', 'y' }
    local tsize = { x = screen.text_extents(txt), y = a.font_size * (1 - a.font_headroom) }
    local size = {}
    local b = {}
    local t = {}
    local tmode = {}
    local p = {}
    local align = { x = d.align[1], y = d.align[2] }
    local balign = {}
    local talign = {}

    for i,k in ipairs(ax) do
        if d[k][2] ~= nil then
            size[k] = d[k][2] - d[k][1] - 1

            if not extents then
                b[k] = d[k][1]
                t[k] = b[k] + ((k == 'y') and size[k] + tsize[k] or size[k])/2 - 1

                tmode[k] = 'center'
            end
        else
            p[k] = (type(a.padding) == 'table' and a.padding[i] or a.padding or 0) * 2
            size[k] = tsize[k] + p[k] - 1

            if not extents then
                if align[k] == 'center' then
                    balign[k] = (k == 'x') and (((tsize[k] + p[k]) / 2) + 1) or size[k]/2 - 1
                    talign[k] = (k == 'x') and 0 or (tsize[k]/2)
                elseif align[k] == 'bottom' or align[k] == 'right' then
                    balign[k] = (k == 'x') and (tsize[k] + p[k]) or size[k]
                    talign[k] = (k == 'x') and -1 or -(p[k]/2)
                else
                    balign[k] = 0
                    talign[k] = (k == 'x') and 1 or tsize[k] + (p[k]/2) - 1
                end
                
                b[k] = d[k][1] - balign[k]
                
                if k == 'x' then
                    t[k] = (d[k][1] - 1 + ((p[k] / 2) * talign[k]) - (a.font_face == 1 and (a.font_size * a.font_leftroom) or 0))
                else
                    t[k] = d[k][1] + talign[k]
                end

                tmode[k] = align[k]
            end
        end
    end

    if not extents then
        if a.fill > 0 then
            screen.level(a.fill)
            screen.rect(b.x - 1, b.y - 1, size.x + 1, size.y + 1)
            screen.fill()
        end

        if a.border > 0 then
            screen.level(a.border)
            screen.rect(b.x, b.y, size.x, size.y)
            screen.stroke()
        end

        screen.level(a.lvl)
        screen.move(t.x, t.y)

        if tmode.x == 'right' then
            screen.text_right(txt)
        elseif tmode.x == 'center' then
            screen.text_center(txt)
        else
            screen.text(txt)
        end
    end
    
    return size.x, size.y
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
    if not flow then noflow = false end

    local function setetc(pa, i) 
        for j,k in ipairs { 'font_face', 'font_size', 'lvl', 'border', 'fill', 'font_headroom', 'font_leftroom' } do 
            local w = a[k]
            pa[k] = (type(w) == 'table') and w[i] or w
        end

        pa.padding = a.padding
    end

    local function setax(pa, i, xy)
        for j,k in ipairs(ax) do
            local size = a.size and ((type(a.size) == 'table') and a.size[j] or a.size) or nil

            if size and size ~= 'auto' then
                if pa.align[j] == 'left' or pa.align[j] == 'top' then
                    pa[k] = { xy[k], xy[k] + size }
                else
                    pa[k] = { xy[k] - size, xy[k] }
                end
            else 
                pa[k] = xy[k] or a[k][i]
            end
        end
    end

    if mode == start then
        local j = 1

        local dir, st, en
        if align[flow] == 'left' or align[flow] == 'top' then
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
            pa.align = a.align
            setax(pa, i, iax)

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
            if iax[k] and initax[k] then
                dimt[k] = (iax[k] + ((dim[k] + 1) * 1)) - initax[k]
            end
        end
    elseif mode == justify then
        local ex = {}
        local exsum = { x = 0, y = 0 }
        do
            local pa = {}
            setetc(pa, 1)
            pa.align = (flow == 'x') and { 'left', yalign } or { xalign, 'top' }
            setax(pa, 1, iax)

            ex[1] = {}
            ex[1].x, ex[1].y = place(txt[1], pa)
            exsum[flow] = exsum[flow] + ex[1][flow] + 1
        end

        if #txt > 1 then
            local pa = {}
            setetc(pa, #txt)
            pa.align = (flow == 'x') and { 'right', yalign } or { xalign, 'bottom' }
            setax(pa, #txt, lax)

            ex[#txt] = {}
            ex[#txt].x, ex[#txt].y = place(txt[#txt], pa)
            exsum[flow] = exsum[flow] + ex[#txt][flow] + 1
        end

        if #txt > 2 then
            local pa_btw = {}
            
            for i = 2, #txt - 1, 1 do
                pa_btw[i] = {}
                setetc(pa_btw[i], i)
                pa_btw[i].align = (flow == 'x') and { 'left', yalign } or { xalign, 'top' }
                setax(pa_btw[i], i, iax)

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
                
                setax(pa_btw[i], i, iax)
                place(txt[i], pa_btw[i])
            end
        else
            for i,v in ipairs(ex) do 
                exsum[noflow] = math.max(exsum[noflow], v[noflow])
            end
        end

        dimt[flow] = a[flow][2] - a[flow][1]
        dimt[noflow] = exsum[noflow]

    elseif mode == manual then
        local ex = {} 
        for i,v in ipairs(txt) do 
            local pa = {}   
            setetc(pa, i)
             
            for j,k in ipairs(ax) do 
                local size = a.size and ((type(a.size) == 'table') and a.size[j] or a.size) or nil

                if not flow or flow == k then 
                    pa[k] = a[k][i]

                    if size and size ~= 'auto' then
                        pa[k][2] = pa[k][1] + size
                    end
                else 
                    pa[k] = a[k] 

                    if size and size ~= 'auto' then
                        local one = ((type(pa[k]) == 'table') and pa[k][1] or pa[k])
                        pa[k] = { one, one + size }
                    end
                end
            end

            ex[i] = {}
            ex[i].x, ex[i].y = place(v, pa)
        end
       
        if noflow then
            for i,v in ipairs(ex) do 
                dimt[noflow] = math.max(dimt[noflow], v[noflow])
            end
        end
    end
    
    return dimt.x, dimt.y
end

local function txtline(txt, a)
    --x, y, align, flow, wrap, margin, size

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
            return txtpoint(v, a, true)
        end, 
        a
    )
end

local function txtplane(txt, a)
    --x, y, align, flow, wrap, margin, size

    local start, justify, manual = 1, 2, 3
    local mode = { x = start, y = start }
    local iax = {}
    local lax = {}  
    local ax = { 'x', 'y' }
    
    local flow = a.flow
    local noflow
    
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
 
    for i,k in ipairs(ax) do 
        if k ~= a.flow then noflow = k end 
    end

    local rflow = flow
    local rnoflow = noflow
    if mode.x == manual and mode.y == manual then 
        rflow = false
        rnoflow = false
    end

    local function cb(extents) 
        return function(v, b) 
            setmetatable(b, { __index = a })
            
            liax = {}
            llax = {}
            
            b.flow = rnoflow

            if mode[noflow] ~= manual then
                b[noflow] = a[noflow]

                liax[flow] = b[flow]
                liax[noflow] = iax[noflow]
                llax[flow] = b[flow]
                llax[noflow] = lax[noflow]
            end

            return placeaxis(v, mode[noflow], liax, llax, 
                function(w, a) 
                    if extents then
                        return txtpoint(w, a, true)
                    else
                        return txtpoint(w, a)
                    end
                end, 
                function(w, a) 
                    return txtpoint(w, a, true)
                end, 
                b
            )
        end
    end

    local b = {}
    setmetatable(b, { __index = a })
    b.flow = rflow 
    b.size = false

    return placeaxis(txt, mode[a.flow], iax, lax, cb(false), cb(true), b)
end

_txt = _group:new()
_txt.devk = 'screen'

_txt.enc = _group:new()
_txt.enc.devk = 'enc'

_txt.key = _group:new()
_txt.key.devk = 'key'

_txt.affordance = _screen.affordance:new {
    font_face = 1,
    font_size = 8,
    lvl = 15,
    border = 0,
    fill = 0,
    padding = 0,
    margin = 0,
    x = 1,
    y = 1,
    size = nil,
    flow = 'x',
    align = 'left',
    wrap = nil,
    font_headroom = 3/8,
    font_leftroom = 1/16,
    label = function(s) return s.k end
}

_txt.affordance.output.txt = function(s) return 'wrong' end

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


_txt.enc.number = _enc.number:new()
_txt.affordance:copy(_txt.enc.number)

_txt.enc.number.output.txt = function(s) return s.v end
