# types

[nest_](#nest_) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [print](#print)
  - [connect](#connect)
  - [init](#init)
  - [each](#each)
  - [set](#set)
  - [get](#get)
  - [put](#put)
  - [read](#read)
  - [write](#write)
  
}

[_control](#_control) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [print](#print)
  - [value](#value)
  - [action](#action)
  - [update](#update)
  - [handler](#handler)
  - [redraw](#redraw)
  
}

[_input](#_input) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [handler](#handler)
  
}

[_output](#_output) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [redraw](#redraw)
  
}

[_group](#_control) { }

### nest_

one of the two basic types in `nest_`. for introductory info, see [nests and controls](../study/study1.md)

### _control

one of the two basic types in `nest_`. for introductory info, see [nests and controls](../study/study1.md)

### _group

a simple container type for grouping controls by device or module. ex: `_grid.value`, `_enc.txt.number`

### _input

stores input behaviors of a `_control`

### _output

stores output behaviors of a `_control`

# properties

### p

a link to the parent of a child object

### k

the key of a child object

### z

the order of children within a `nest_` when drawn or updated by a device input. higher z values will be drawn or updated first, default = 0

### enabled

boolean value, sets whether a given object and its children are drawn + updated. useful for pagination !

### value

the definitive datapoint of a control. this is the only property expected to change dynamically, though it can be initialized just like any other property. different controls will expect different datatypes and range constraints. along with `p`, `k`, and `z`, a pointer function cannot be assigned to `value`.

# methods

### print

### connect

assigns a table of device keys and values to a nest structure and initializes it. this might look something like:

```
nest_{
  ...

} :connect {
  g = grid.connect(),
  screen = screen,
  key = key,
  enc = enc
}
```

the device key value pairs are:

```
g = grid.connect(n), 
a = arc.connect(n), 
m = midi.connect(n), 
h = hid.connect(n), 
screen = screen, 
enc = enc, 
key = key

```

### init

user-defined method called immediately after a nest structure has been initialized, usually via `nest_:connect()`

### update

this should be ran after updating `_control.value` in order call the `action` method and signal a device to be redrawn.

### action

a typically user-defined method called whenever `update` is called either manually or by a device, usually when `value` has changed. any return value will in turn assigned `value`, so the action can be used as a filter if desired

### handler

user-defined or type-defined method to convert device input (as arguments) into a value. additional return values are sent as arguments to `action`. this might look something like:

```
handler = function(s,v,x,y,z)
  if z == 1 then 
    return 1
  else
    return 0
  end
end
```

### redraw

user-defined or type-defined method to convert a value into device output. `value` and a device object are sent as arguments. this might look something like:

```
redraw = function(self, value, g)
  if value == 1 then
    g:led(self.x, self.y, 15)
  else
    g:led(self.x, self.y, 0)
  end
end
```

### set

### get

### put

### write

### read
