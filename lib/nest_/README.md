```

ADD

add :each(function(k, _)) to _obj_. these would run after the top level table has been initialized, which helps to enable absolute paths to be used within a nest structure

add actions{} list of action function keys in self
add inits{} list of init function keys in self, return table members assigned to self
add targets{} list of target nest keys in self 

handler(), control() -> action[1]()i -> ... -> anction[n] -> v (catch nill returns)

_nest: do_init() -> pre_init() -> init() -> bang

create _control._call metatmethod as a set/bang/get function. if first arg is control, ignore it

add :link(_control or function() return control end) to _control, link two controls by appending actions



add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

IMPLIMENT

enabled

```
