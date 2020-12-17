# core

```

RENAME

lvl -> level. add a lvl as a nickname
add en as a nickname for enabled
zsort -> children. require children to be nest_'s

ADD

support nest_.redraw, overrides draw children

_obj_.metatable - allow access to the metatable for e.g. reassigning the __call metamethod, which is both useful when pointed to new and set. ?? what if we defaulted it to set but overrode it for library objects? 
simpler solution would just be adding a property called __call which the metatable references. the other things we probs don't want to expose

support _affordance { input = false } properly when input already exists. use booleans in the constructor to essentially nullify default values, even when they are _obj_ (i.e., members of zsort)


nest_.focus - focus on a single nest & children for a device & effectively disable otherelatives. will need it's own variable in the _dev. great for popup interfaces

nest_ get/set: table macros nest = { nest = { control = value } } 

_obj_:put() macro for appending /replacing any values within an _obj_ structure - useful for setting up multiple templates then filling in shared data

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

add actions{} list of action functions
add inits{} list of init functions
add creates{} list of creation time functions
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions when values are the same type. also allow link to param (overwrites param action)

```
# norns
```
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
_etc.et24_
_etc.filebrowser_

```

# grid
```

ADD

_grid.control.wrap

_grid.numtog ?
_grid.shape (eathsea) named combinations of normalized trigger presses for line & plane. add the naming feature to trigger ? (un-normalized)

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

