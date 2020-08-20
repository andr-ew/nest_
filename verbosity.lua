nest_:new({
        page = value:new({
            y = 0,
            x = { 0, 1 }
        }),
        page1 = {
            gain = fader:new({
                x = 0,
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            }),
            overdub = fader:new({
                x = 1,
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            }),
            pan = crossfader:new({
                x = 2,
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            })
        },
        page2 = {
            gain = fader:new({
                x = 0,
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            }),
            overdub = fader:new({
                x = 1,
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            }),
            pan = crossfader:new({
                x = 2,
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            })
        }
    }
)

-------------------------------------------

nest_:new({
        page = value:new({
            y = 0,
            x = { 0, 1 }
        }),
        page1 = {
            gain = fader:new({
                x = 0
            }),
            overdub = fader:new({
                x = 1
            }),
            pan = crossfader:new({
                x = 2
            }),
            gene = gene:new({
                y = {0, 6},
                show = function()
                    return c.page.v == 0
                end
            })
        },
        page2 = {
            gain = fader:new({
                x = 0
            }),
            overdub = fader:new({
                x = 1
            }),
            pan = crossfader:new({
                x = 2
            }),
            gene = gene:new({
                y = {0, 6},
                show = function()
                    return c.page.v == 1
                end
            })
        }
    }
)

-------------------------------------------

nest_:new({
        page = value:new({
            y = 0,
            x = { 0, 1 }
        }),
        pages = {
            {
                gain = fader:new(),
                overdub = fader:new(),
                pan = crossfader:new()
            },
            {
                gain = fader:new(),
                overdub = fader:new(),
                pan = crossfader:new()
            },
            gene:new({
                y = {0, 6},
                x = index,
                show = function()
                    return c.page.v == parent.index
                end
            })
        }
    }
)

---------------------------------------

f = nest_:new{
    page = value:new({
        y = 0,
        x = { 0, 1 }
    })
    pages = {}
}

for i = 1, 2 do
    f.pages[i] = {
        gain = fader:new(),
        overdub = fader:new(),
        pan = crossfader:new()
    }
end

f.pages.add(gene:new {
    y = {0, 6},
    x = self.index,
    show = function()
        return f.page.v == self.parent.index
    end
})

---------------------------------------

c = nest_:new { p = v:n({ 0, 1 }, 0), pgs = {} }
for i = 1, 2 do c.pgs[i] = { g = f:n(), o = f:n(), p = cf:n() } end
c.pgs.add(gn:n{ y = {0, 6}, x = slf.i, sh = function() return c.p.v == slf.par.i end });