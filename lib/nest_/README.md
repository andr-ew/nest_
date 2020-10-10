```

REFACTOR

convention: allow most data parameters to be a value or a function returning the desired value. current _grid. imlimentations will need to change. to impliment this we can create a blank par table as a proxy. par will index the same as _i/o, but if the value is a function, it'll return the return the return value of the function rather than the function itself

TEST

--------------

ADD

when nest_ arg type is not table add a number range or key list argument option to initialize blank table children at specified keys

add :each(function(k, _)) to _obj_. these would run after the top level table has been initialized, which helps to enable absolute paths to be used within a nest structure

add actions{} list of action function keys in self
add inits{} list of init function keys in self, return table members assigned to self
add targets{} list of target nest keys in self 

handler(), control() -> action[1]()i -> ... -> anction[n] -> v (catch nill returns)

_nest: do_init() -> pre_init() -> init() -> bang

create _control._call metatmethod as a set/bang/get function. if first arg is control, ignore it

add :link(_control or function() return control end) to _control, link two controls by appending actions



add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child


RM

throw

IMPLIMENT

enabled

```
