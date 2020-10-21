# grid
```
ADD

_grid.range
_grid.fader

action arg defaults

control
fill (output only)
range
value
trigger
momentary
toggle
fader { range = { 0, 1 } }

grid.andrew.glide (2nd input inside a value)

metacontrol
pattern
preset

REFACTOR

seperate count into count and fingers. fingers sets a range of held keys requred for an action to occur, count sets the range of values that may be present at one time. in momentary these are the same concept, but in the other objects they are seperate. in order to impliment the ideas seprately the reused guts of momentary need to be abstracted into more flexble utility functions

```

# arc

```
value
fader
arc
switch
cycle { range = { -1, -1 }, step = 1/64 }

pattern
preset

```

# core

```
ADD

rename _device back to _group lol

nest_ get/set: table macros nest = { nest = { control = value } } 

_obj_:put() macro for appending /replacing any values within an _obj_ structure - useful for setting up multiple templates then filling in shared data

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

consider mapping new to _obj_.__call and switching the get/set macro to nest_.v()

add actions{} list of action function keys in self
add inits{} list of init function keys in self, return table members assigned to self
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions

```
