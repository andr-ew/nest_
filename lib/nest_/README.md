# norns
```
_enc.control { n = 1 }
_enc.muxcontrol
_enc.metacontrol
_enc.muxmetacontrol
_enc.preset

_key.control { n = 2, edge = 1 }
_key.muxcontrol
_key.metacontrol
_key.muxmetacontrol
_key.pattern
_key.preset

_screen.control { lvl = 15, aa = 0 }
_screen.output

_grid.control
_grid.output
_grid.input
_grid.muxcontrol
_grid.metacontrol
_grid.muxmetacontrol
_grid.preset
_grid.pattern
_grid.muxpattern

_arc.control
_arc.output
_arc.input
_arc.metacontrol
_arc.pattern
_arc.preset

```

# txt
```
_screen.txt.control {
    input1
    input2
    input3
    n = 2 or { 2, 3 } or { { 2, 3 }, 3 }
    font = 1
    size = 4
    lvl = 15
    border = 0
    fill = 0
    padding ?
    align = 'left' or 'center' or 'right'
    x = 1
    y = 1
    label = self.k or {}
}

_screen.txt.label { value = '' }

_enc.txt.scrollbox {
    x = 1 or {}
    y = 1 or {}
    n = 2 or { 2, 3 }
    lvl = { 2, 15 }
    border = {}
    fill = {}
    cell = self.size + ? or { self.size + ?, self.size + ? } 
    flow = 'x' or 'y'
    fixed = nil
    items = nest_ {} or { {}, ... }
}

_enc.txt.control {
    n = 2 or { 2, 3 }
}

_enc.txt.number {
    controlspec
    range = { 0, 1 }
    step = 1
    warp = 1
}

_enc.txt.option {
    list = {}
}

_enc.txt.radio {
    list = {} or { {}, ... }
    wrap = 4
    flow = 'x' or 'y'
}

_key.txt.option {
    n = 2 or { 2, 3 }
    list = {}
    inc
}

_key.txt.radio {
    n = 2 or { 2, 3 }
    list = {}
    wrap = 4
    flow = 'x' or 'y'
    inc
}

_key.txt.trigger {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    fingers = { 0, 3 }
    flow = 'x' or 'y'
    edge = 1
}

_key.txt.momentary {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    fingers = { 0, 3 }
    flow = 'x' or 'y'
    edge = 1
}

_key.txt.toggle {
    n = 2 or { 2, 3 } or { 1, 2, 3 }
    lvl = { 0, ..., 15 } 
    flow = 'x' or 'y'
    fingers = { 0, 3 }
    edge = 1
}

_txt.et24

```


# grid
```

RENAME

_grid.value -> _grid.number

ADD

_grid.control.wrap

_grid.numtog ?

_grid.pattern
_grid.switchpat --switch btw multiple patterns
_grid.preset

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

v -> value

ADD

bring back single letter aliases

nest_ get/set: table macros nest = { nest = { control = value } } 

_obj_:put() macro for appending /replacing any values within an _obj_ structure - useful for setting up multiple templates then filling in shared data

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

consider mapping new to _obj_.__call and switching the get/set macro to nest_.v()

add actions{} list of action function keys in self
add inits{} list of init function keys in self, return table members assigned to self
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions when values are the same type. also allow link to param (overwrites param action)

```
