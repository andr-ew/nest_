# norns
```
MAP

_key.binary

_key.momentary {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    fingers = { 0, 3 }
    edge = 1
}

_key.trigger {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    fingers = { 0, 3 }
    edge = 1
}

_key.toggle {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    lvl = { 0, ..., 15 } 
    fingers = { 0, 3 }
    edge = 1
}

_key.number {
    n = 2 or { 2, 3 }
    inc = 1
}

_key.option {
    options = {}
}

_enc.number {
    range = { 0, 1 },
    wrap = false
}

_enc.control {
    controlspec
    range = { 0, 1 }
    step = 1
    warp = 1
    wrap = false
}

_enc.option {
    options = {}
}

```

# txt
```

redraw = function()
    self:placer(self:txt())
end

_screen.txt.control {
    n = 2 or { 2, 3 } or { { 2, 3 }, 3 }
    font = 1
    size = 4
    lvl = 15
    border = 0
    fill = 0
    padding ?
    x = 1 or {}
    y = 1 or {}
    flow = 'x' or 'y'
    wrap = nil or 5
    label = self.k or {}
}

_screen.txt.label { value = '' }

_txt.list_ {
    x = 1 or {}
    y = 1 or {}
    lvl = { 2, 15 }
    border = {}
    fill = {}
    cellsize = self.size + ? or { self.size + ?, self.size + ? } 
    flow = 'x' or 'y'
    items = nest_ {} or { {}, ... }
}

_txt.select_ {
}

_txt.scroll_ {
    x = 1 or {}
    y = 1 or {}
    lvl = { 2, 15 }
    border = {}
    fill = {}
    cellsize = self.size + ? or { self.size + ?, self.size + ? } 
    flow = 'x' or 'y'
    window = 6 or { 6, 6 }
    items = nest_ {} or { {}, ... }
}

_txt.enc.control {
    n = 2 or { 2, 3 }
}

_txt.enc.number {
    controlspec
    range = { 0, 1 }
    step = 1
    warp = 1
}

_txt.enc.option {
    options = {}
}

_txt.enc.radio {
    options = {} or { {}, ... }
}

_txt.key.option {
    n = 2 or { 2, 3 }
    options = {}
    inc
}

_txt.key.radio {
    n = 2 or { 2, 3 }
    options = {}
    inc
}

_txt.key.trigger {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    fingers = { 0, 3 }
    edge = 1
}

_txt.key.momentary {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    fingers = { 0, 3 }
    edge = 1
}

_txt.key.toggle {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    lvl = { 0, ..., 15 } 
    fingers = { 0, 3 }
    edge = 1
}

```

# etc
```
_etc.et24
_etc.fselect

```

# grid
```

ADD

_grid.control.wrap

_grid.numtog ?

_grid.pattern
_grid.switchpat --switch btw multiple patterns
_grid.preset

REFACTOR

embed controlspec in grid.fader, align properties with argument names
add min and max to number

```

# arc

```
number
fader
fill
range
toggle
cycle { range = { -math.huge, math.huge }, step = 1/64, wrap = 1 }

pattern
preset

```

# core

```

RENAME

control -> affordance ???
in this case, fader can become control + get a little closer to the norns standard. we can name certain affordances the same as the params name and make the possible linkages clearer. I'm lichen it !


ADD

support nest_.redraw, overrides draw children

nest_ get/set: table macros nest = { nest = { control = value } } 

_obj_:put() macro for appending /replacing any values within an _obj_ structure - useful for setting up multiple templates then filling in shared data

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

add actions{} list of action function keys in self
add inits{} list of init function keys in self, return table members assigned to self
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions when values are the same type. also allow link to param (overwrites param action)

```
