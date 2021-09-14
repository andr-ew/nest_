[nest_](#nest_) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [observable](#observable)
  - [persistent](#persistent)
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
 - [:connect()](#connect)
 - [:get()](#get)
 - [:set()](#set)
 - [:each()](#each)
 - [:merge()](#merge)
 - [:param()](#param)

[_affordance](#_affordance) {
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
  - [input](#_input)
  - [output](#_output)
  
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

[_group](#_affordance) { }

[_observer](#_observer) {
   - [target](#target)
   - [capture](#capture)
   
}

[_preset](#_preset) {
  - [target](#target)
  - [capture](#capture)
  - [store](#store)
  - [recall](#recall)

}

[_pattern](#_pattern) {
   - [target](#target)
   - [capture](#capture)
   - 
}
   - [:rec_start()](#rec_start)
   - [:rec_stop()](#rec_start)
   - [:start()](#start)
   - [:resume()](#resume)
   - [:set_overdub()](#set_overdub)
   - [:set_time_factor()](#set_time_factor)

# core types

### nest_

one of the two basic types in `nest_`. for introductory info, see [nests and affordances](../study/study1.md)

### _affordance

one of the two basic types in `nest_`. for introductory info, see [nests and affordances](../study/study1.md)

### _group

a simple container type for grouping affordances by device or module. ex: `_grid.value`, `_txt.enc.number`

### _input

stores input behaviors of a `_affordance`, data is independent of `_output`

### _output

stores output behaviors of a `_affordance`, data is independent of `_input`

### _observer

stores observation behavior & data for meta-affordances

###  _preset

an observer subtype for preset meta-affordances

###  _pattern

an observer subtype for pattern meta-affordances

# properties

### p

a link to the parent of a child object

### k

the key of a child object

### z

the order of children within a `nest_` when drawn or updated by a device input. higher z values will be drawn or updated first, default = 0. [here's](https://gist.github.com/andr-ew/1c8bc88e260eace46e69615c3874513e) an example of usage!

### enabled

boolean value, sets whether a given object and its children are drawn + updated. useful for pagination !

### value

the definitive datapoint of an affordance. this is the only property expected to change dynamically, though it can be initialized just like any other property. different affordances will expect different datatypes and range constraints. along with `p`, `k`, and `z`, a pointer function cannot be assigned to `value`.

### target

the `nest_`, `_affordance`, or table of nests/affordances that will pass data to the `_observer` whenever an affordance `value` is updated.

### capture

the data that is passed from the `target`s to the `_observer`. usually this is type-defined. possible values are:
- `"input"`: arguments passed to the [`handler`](#handler) function
- `"action"`: arguments passed to the [`action`](#action) function (the first argument is `value`)
- `"value"`: the value of the affordance only

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

this should be ran after updating `_affordance.value` in order call the `action` method and signal a device to be redrawn.

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

### each

see study 2

### merge(nest)

recursively sum this nest with `nest`

### write

### read

### param(id)

bind affordance to param id of `id`

### store

`_pattern:store(n)`

store the target value(s) to the nth preset slot

### recall

`_pattern:store(n)`

push the value(s) in the nth preset slot to the target(s)

### rec_stop 
see [http://norns.local/doc/classes/pattern.html](http://norns.local/doc/classes/pattern.html)
### rec_start 
see [http://norns.local/doc/classes/pattern.html](http://norns.local/doc/classes/pattern.html)
### stop 
see [http://norns.local/doc/classes/pattern.html](http://norns.local/doc/classes/pattern.html)
### play 
see [http://norns.local/doc/classes/pattern.html](http://norns.local/doc/classes/pattern.html)
### set_overdub 
see [http://norns.local/doc/classes/pattern.html](http://norns.local/doc/classes/pattern.html)
### set_time_factor
see [http://norns.local/doc/classes/pattern.html](http://norns.local/doc/classes/pattern.html)
### resume
play the pattern without restarting to the beginning


