# arc

```
remove v from fill

fill {
    n = 1,
    x = { 1, 64 },
    aa = false,
    lvl = 15
}

delta {
    n = 1
}

number {
    n = 1,
    x = { 33, 32 },
    aa = false,
    lvl = 15,
    range = { 0, 1 },
    inc = 1/64, 
    step = 1/64,  
    sens = 1,
    indicator = 1,
    wrap = false
    -- v = v + (d * sens * inc * (step * 64)) (clamp range, wrap)
    -- ledx = x[1] + ((v * inc) // (x[2] - x[1])) (start indicator)
}

control {
    n = 1,
    x = { 42, 24 },
    aa = false,
    lvl = 15,
    controlspec
    range = { 0, 1 },
    step = 0.01,
    units = '',
    quantum = 0.01,
    warp = 'lin',
    wrap = false
}

option {
    n = 1,
    x = { 33, 32 },
    aa = false,
    lvl = 15,
    sens = 1,
    range = { 1, 4 },
    include = { 1, 2, 4 },
    glyph = function(s, v) end
    options = 4,
    margin = 0
}

?
toggle {
    n = 1,
    x = { 33, 32 },
    aa = false,
    lvl = { 0, 15 },
    sens = 1,
    range = { 1, 2 },
} 
?

(simple versions, n is number)
_arc.key.trigger
_arc.key.momentary
_arc.key.toggle

pattern
preset

```

# core

```

RENAME

lvl -> level. add a lvl as a nickname
add en as a nickname for enabled
zsort -> children. require children to be nest_'s

REFACTOR

consider splitting up "value" into a raw value (state) and a user facig value (meaning). the difference between these two concepts is made most evident by the option types.

implimentation could be an actual value ("raw", maybe keep the nickname "v" for now to avoid measurable refactoring work) and a key (stick with "value") which is a (non-silent) proxy to getter/setter functions.

_affordance:refresh() instead of argumentless update, just to manually dirty the flag after any manual property change (value or otherwise)

create readonly properties, which cannot be overwritten outside of the p_ proxy or a constructor. the _ table can basically become this. when the obj is printed, don't print functions in this table, we can put the builtins here and hide them on user print. properties like x, y, n, which we don't want to be editable after creation, can be put in this table after initialization

ADD

support nest_.redraw, overrides draw children

_obj_.metatable - allow access to the metatable for e.g. reassigning the __call metamethod, which is both useful when pointed to new and set. ?? what if we defaulted it to set but overrode it for library objects? 
simpler solution would just be adding a property called __call which the metatable references. the other things we probs don't want to expose

support _affordance { input = false } properly when input already exists. use booleans in the constructor to essentially nullify default values, even when they are _obj_ (i.e., members of zsort)

support _affordance { input = { enabled = false } }: for members objects that exist in the contructor object, sending a table :put()s that table in the existing object

nest_.focus - focus on a single nest & children for a device & effectively disable otherelatives. will need it's own variable in the _dev. great for popup interfaces

nest_ get/set: table macros nest = { nest = { control = value } } 

_obj_:put() macro for appending /replacing any values within an _obj_ structure - useful for setting up multiple templates then filling in shared data

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

add actions{} list of action functions
add inits{} list of init functions
add creates{} list of creation time functions
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions when values are the same type. also allow link to param (overwrites param action)

nest:disconnect() : for disconnecting and reconnecting nests to devices

```
# norns
```
ADD 

_enc.delta
_enc.affordance.sens (impliment in input.filter, v easy) also: fine tune range delta stuff for option as in _arc.option

```

# txt
```

RENAME

left, right, top, bottom -> start, end

ADD

underline property

sumbmenus inside list:

items = nest_ {
    nest_ {
        label = 'more items',
        items = {
        }
    },
    nest_ {
        label = 'even more items',
        nest_ {
            label = 'yet more items',
            items = {
            }
        }
        items = {
        }
    }
}

display strings inside list.itmes like headers in the params menu

```

# etc
```
_etc.et12
_etc.et24
_etc.filebrowser

```

# grid
```

ADD

_grid.affordance.wrap

_grid.toggle: range argument

_grid.numtog ?
_grid.shape (eathsea) named combinations of normalized trigger presses for line & plane. add the naming feature to trigger ? (un-normalized)

_grid.pattern
_grid.switchpat --switch btw multiple patterns
_grid.preset

REFACTOR

remove v from fill

grid.fader -> grid.control
embed controlspec in grid.fader, align properties with argument names

add range to number, default to 1-based

```
