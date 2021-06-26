[_grid.affordance](#affordance) {
  - [x](#x)
  - [y](#y)
  - value
  - [lvl](#lvl)
  - [edge](#edge)
  - [count](#count)
  - [fingers](#fingers)
  - wrap
  - [action](#action)

}

[_grid.fill](#fill) { ... }

[_grid.number](#number) { ... }

[_grid.control](#control) {
  - ...
  - [min](#min)
  - [max](#max)
  - [controlspec](#controlspec)
  
}

[_grid.trigger](#trigger) { ... }

[_grid.momentary](#momentary) { 
  - ... 
  - [clear](#clear)
  
}

[_grid.toggle](#toggle) { 
  - ... 
  - include
  - min
  - max
  
 }

[_grid.range](#range) { ... }

[_grid.pattern](#pattern) { 
  - ... 
  - [target](../doc/core.md#target)
  - [stop](#stop)
 
}

[_grid.preset](#preset) { 
  - ... 
  - [target](../doc/core.md#target)
 
 }

# affordances

### affordance

the base affordance type for the grid module - all other grid affordances inherit from this device and share common properties. the user may extend this type in order to define a custom grid affordance:

```
two_by_two = _grid.affordance {
  x = { 1, 2 }, y = { 1, 2 }, lvl = 15, v = { x = 0, y = 0 },
  handler = function(s,v,x,y,z)
    if z == 1 then 
      return { x = x - x[1], y = y - y[1] }
    end
  end,
  redraw = function(s,v,g)
    g:led(s.x[1] + v.x, s.y[1] + v.y, s.lvl)
  end,
  action = function(s,v)
    print(v.x, v.y)
  end
}
```

### fill

a simple output-only affordance which draws the provided `x` and `y` dimentions to the provided brightness level

### number

a integer or "radio button" style affordance for which an integer `value` is assinged to index of the last key pressed. `x` and `y` dimentions set the size of the affordance and the range of `value`.

### control

like the `paramset` "control" type, a number with musicaly convenient properties. a `controlspec` is used internally, which may be provided at init time rather than properties.

### trigger

an affordance that blinks for `blinktime` seconds and runs `action` on keypress. `x` and `y` dimentions set up a matrix of values.

### momentary

a "held" button where `value` goes high where a key is depressed, low where a key is released. `x` and `y` dimentions set up a matrix of values.

### toggle

a button where `value` toggles between high and low on a keypress. `x` and `y` dimentions set up a matrix of values. if `lvl` has a table length greater than two, a `toggle` button will cycle forward through those brightness values.

### range

responds only to a two-finger press and fills a range of keys, setting `value = { finger1, finger2 } `

# meta-affordances

### pattern

a pattern recorder, loops any input recieved by the [`target`(s)](../doc/core.md#target). `x` and `y` dimentions set up a bank of pattern recorders. setting the property `count = 1` creates a "choke group" bank, with only one pattern slot playing back at a time. 

unlike regular affordances, meta-affordances have thier [`action`](#action) functions & behaviors pre-defined ([`lvl`](#lvl) is also predefined). a single press toggles between recoding, playback & pause. double-tap a recorded pattern to overdub, and hold for `> 0.5s` to clear the pattern slot. reference source code if you wish to redefine behavior & appearence.

### preset

a preset switch, stores and recalls values of the [`target`(s)](../doc/core.md#target). `x` and `y` dimentions set the size of the switch & the number of preset slots.

unlike regular affordances, meta-affordances have thier [`action`](#action) functions & behaviors pre-defined ([`lvl`](#lvl) is also predefined). by default only the first slot will have a value stored. pressing a blank slot key will store the current settings in that slot, and switching back to an earlier slot will recall the previous setting. reference source code if you wish to redefine behavior & appearence.


# properties

### x

the horizontal component of an affordance's location. can assign either a single integer for a single key or a table of two integers specifying start and end keys on the x axis. all grid affordances can thus be 0-dimentional, 1-dimentional, or 2-dimentional.

### y

the vertical component of an affordance's location. can assign either a single integer for a single key or a table of two integers specifying start and end keys on the y axis. all grid affordances can thus be 0-dimentional, 1-dimentional, or 2-dimentional.

### value

the affordance value. the format of value depends on the affordance type and the `x` and `y` dimentions - it may either be a single number or a table of numbers. see types for details.

### lvl

sets the brightness levels for the affordance. for most types, assigning a single integer sets the "on" level and assigning a table of two sets the "off" and "on" levels. a member of the lvl table may be a clock function, and a pointer function assigned to lvl will receive additional `x` and/or `y` arguments for relative offset being filled. 

### min

minimum output `value`.

### max

maximum output `value`.

### edge

sets whether to respond to the rising edge of an input (`'rising'`), falling edge (`'falling'`), or both edges (`'both'`). will sometimes affect the behavior of the `time` argument.

### count

when `value` is a table, restricts the number of simultaneous high values to the range given by `count = { min, max }`

### fingers

restricts the number of simultaneous finger presses to which an affordance will respond to the range `fingers = { min, max }`


# methods

### action

there may be up to six arguments passed to any grid action in addition to `self`:
```
action = function(self, value, time, delta, add, rem, list)
  print(value, time, delta, add, rem, list)
end
```

1. `value`: the affordance value. the format of value depends on the affordance type and the `x` and `y` dimentions - see types for details.
2. `time`: the amount of time in seconds that an affordance is held before releasing. may be either a single number or a table of numbers following the format of `value`.
3. `delta`: a bit of a wildcard - this may eiter represent the change in `value` or the change in time between sucessive interactions. may be either a single number or a table of numbers following the format of `value`.
4. `add`: when `value` is a table of numbers, `add` is passed the index that has turned from 0 to 1 if it exists
5. `rem`: when `value` is a table of numbers, `rem` is passed the index that has turned from 1 to 0 if it exists
6. `list`: when `value` is a table of numbers, list is a table of indicies in `value` which are > 0

### stop

if provided, `stop(self)` is called when any `_pattern` slots are paused or cleared. useful for [`clear`](#clear)ing hung values from `momentary` affordances.

### clear

resets `momentary` to a clear state, useful for dealing with hung states.
