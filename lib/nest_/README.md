# grid
```
ADD

_grid.range
_grid.fader

action arg defaults

BUG

toggle.fingers unsupported, toggle.egde == 0 & toggle.count don't work as expected, trigger.count unsuported, trigger.fingers[2] does not work as expected (works more like count)

need refactor of toggle + binary

COLLECTION

control
fill (output only)
range
value
trigger
momentary
toggle
fader { range = { 0, 1 } }

metacontrol
pattern
preset

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
