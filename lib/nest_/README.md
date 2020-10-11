# core

```

ADD

_nest: do_init() -> pre_init() -> init() -> bang

create _control._call metatmethod as a set/bang/get function. if first arg is control, ignore it

nest_ get/set: table macros nest = { nest = { control = value } } 

add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

ADD

add actions{} list of action function keys in self
add inits{} list of init function keys in self, return table members assigned to self
add targets{} list of target nest keys in self 

add :link(_control or function() return control end) to _control, link two controls by appending actions

```

# grid

```


```
