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
  
}

[_group](#_control) { }

### nest_

one of the two basic types in `nest_`. for introductory info, see [nests and controls](../study/study1.md)

### _control

one of the two basic types in `nest_`. for introductory info, see [nests and controls](../study/study1.md)

### _group

a simple container type for grouping controls by device or module. ex: `_grid.value`, `_enc.txt.number`

# properties

### p

a link to the parent of a child object

### k

the key of a child object

### z

the order of children within a `nest_` when drawn or updated by a device input. higher z values will be drawn or updated first, default = 0

### enabled

boolean value, sets whether a given object and its children are drawn + updated. useful for pagination !

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

method called immediately after a nest structure has been initialized, usually via `nest_:connect()`
