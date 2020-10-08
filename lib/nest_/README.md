```

REFACTOR

remove _meta functionality

create the devs table and _dev object

local _dev = {
    dirty = true,
    object = grid/arc/screen/enc/key/etc,
    redraw = function() end,
    handler = function() end
}

devs = {
    screen,
    key,
    enc,
    g,
    a,
    m,
    h
}

:connect adds a link to the devices table (table, not _obj_, make sure it doesn't become _obj_) to every child/grandchild as well as g, a, etc (/vport device) links

clean up redraws: rather than redraw on any input, set up a global 30fps redraw metro and a global dirty flag per device. :update() or _control() sets the dirty flag 

-----------------

in control.update(), pass both the handler args and resulting value to _metacontrol, metacontrol decides what to store and recall. (.mode = 'v' or 'handler' for default pattern control)

revert _metacontrol implimentation back to the method used in branch/dead-things-from-christman

--------------------

refactor _control as subtype of nest_ ( benefit: shared update(), draw(), consistency )

remove inputs{}, outputs{}; _input, _output simply refer to o, p (, meta), then self for members, control searches self for _inputs & _outputs to update

convention: allow most data parameters to be a value or a function returning the desired value. current _grid. imlimentations will need to change. to impliment this we can create a blank par table as a proxy. par will index the same as _i/o, but if the value is a function, it'll return the return the return value of the function rather than the function itself

--------------

ADD

when nest_ arg type is not table add a number range or key list argument option to initialize blank table children at specified keys

add :each(function(k, _)) to _obj_. these would run after the top level table has been initialized, which helps to enable absolute paths to be used within a nest structure

add actions{} table, alias action to actions[1] 
OR add actions table as a list of keys in self

handler(), _control() -> action[1]()i -> ... -> anction[n] -> v (catch nill returns)

create _control.__call metatmethod as a set/bang/get function. if first arg is control, ignore it

add :link(_control or function() return control end) to _control, link two controls by appending actions

add _nest.init = function() end param, init return table members are assigned to _nest (inits{} list of keys in self ?)

_nest: do_init() -> pre_init() -> init() -> bang


add path functionality to _obj_: construct relative string path from parent to child and evalue string path to child

```
