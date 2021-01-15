# core

```

RENAME

lvl -> level. add a lvl as a nickname
add en as a nickname for enabled
zsort -> children. require children to be nest_'s

REFACTOR

_metaaffordace.target: table of nests rather than single nest ?

delegate most of the facilities of _obj_ into _input/_output/nest_. _obj_ should house only the copy & new behavior

ADD

_obj_:put() macro for appending /replacing any values within an _obj_ structure - useful for setting up multiple templates then filling in shared data

support _affordance { input = false } properly when input already exists. use booleans in the constructor to essentially nullify default values, even when they are _obj_ (i.e., members of zsort)

nest_.redraw

nest_.focus - focus on a single nest & children for a device & effectively disable otherelatives. will need it's own variable in the _dev. great for popup interfaces

add actions{} list of action functions
add inits{} list of init functions
add creates{} list of creation time functions
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions when values are the same type. also allow link to param (overwrites param action)

nest:disconnect() : for disconnecting and reconnecting nests to devices

```
# readme

```
build personalized interfaces as a waypoint into existing musical processes (a sampler, a synth voice, a sequence)

```

# arc

```
REFACTOR

remove v from fill
arc.option: store v as an int & store the float remainder from delta values as a seperate float

ADD

pattern
preset

```

# norns
```
ADD 

_grid.binary.lvl -- accept clock funtion entry in table as animation

trigger & toggle t argument: restrict to range of held time when edge == 0

_enc.delta
_enc.affordance.sens (impliment in input.filter, v easy) also: fine tune range delta stuff for option as in _arc.option

*.option: remove the option string action argument, encourage indexing options instead

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

_grid.preset (number)

trigger & toggle t argument: restrict to range of held time when edge == 0 

REFACTOR

grid.fader -> grid.control
embed controlspec in grid.fader, align properties with argument names

add range to number, default to 1-based

```

?????
```
_grid.affordance.wrap ?
_grid.shape (eathsea) named combinations of normalized trigger presses for line & plane. add the naming feature to trigger ? (un-normalized)

remove v from fill ?

? _obj_.metatable - allow access to the metatable for e.g. reassigning the __call metamethod, which is both useful when pointed to new and set. ?? what if we defaulted it to set but overrode it for library objects? 
simpler solution would just be adding a property called __call which the metatable references. the other things we probs don't want to expose

? consider splitting up "value" into a raw value (state) and a user facig value (meaning). the difference between these two concepts is made most evident by the option types.

implimentation could be an actual value ("raw", maybe keep the nickname "v" for now to avoid measurable refactoring work) and a key (stick with "value") which is a (non-silent) proxy to getter/setter functions.

? create readonly properties, which cannot be overwritten outside of the p_ proxy or a constructor. the _ table can basically become this. when the obj is printed, don't print functions in this table, we can put the builtins here and hide them on user print. properties like x, y, n, which we don't want to be editable after creation, can be put in this table after initialization

```
