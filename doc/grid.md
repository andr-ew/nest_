# types

[_grid.control](#control) {
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

[_grid.value](#value) { ... }

[_grid.fader](#fader) {
  - ...
  - range
  
}

[_grid.trigger](#trigger) { ... }

[_grid.momentary](#momentary) { ... }

[_grid.toggle](#toggle) { ... }

[_grid.range](#range) { ... }

_grid.pattern { ... }

_grid.preset { ... }


### control

the base control type for the grid module - all other grid controls inherit from this device and share common properties. the user may extend this type in order to define a custom grid control:

```
two_by_two = _grid.control {
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

a simple output-only control which draws the provided area to the provided brightness level

### value

a "radio button" style control for which an integer `value` is assinged to index of the last key pressed

### fader

a fader style value with a decimal `value` in the range of `range = { min, max }`

### trigger

### momentary

### toggle

### range

# properties

### x

the horizontal component of a control's location. can assign either a single integer for a single key or a table of two integers specifying start and end keys on the x axis. all grid controls can thus be 0-dimentional, 1-dimentional, or 2-dimentional.

### y

the vertical component of a control's location. can assign either a single integer for a single key or a table of two integers specifying start and end keys on the y axis. all grid controls can thus be 0-dimentional, 1-dimentional, or 2-dimentional.

### value

the control value. the format of value depends on the control type and the `x` and `y` dimentions - it may either be a single number or a table of numbers. see types for details.

### lvl

sets the brightness levels for the control. for most types, assigning a single integer sets the "on" level and assigning a table of two sets the "off" and "on" levels

### edge

an integer that sets whether to respond to the rising edge of an input (1), falling edge (0), or both edges (2). will likely affect the behavior of the `time` argument.

### count

when `value` is a table, restricts the number of concurrent 1 values to the range given by `count = { min, max }`

### fingers

restricts the number of simultaneous finger presses to which a control will respond to the range `fingers = { min, max }`


# methods

### action

there may be up to six arguments passed to any grid action in addition to `self`:
```
action = function(self, value, time, delta, add, rem, list)
  print(value, time, delta, add, rem, list)
end
```

1. `value`: the control value. the format of value depends on the control type and the `x` and `y` dimentions - see types for details.
2. `time`: the amount of time in seconds that a control is held before releasing. may be either a single number or a table of numbers following the format of `value`.
3. `delta`: a bit of a wildcard - this may eiter represent the change in `value` or the change in time between sucessive interactions. may be either a single number or a table of numbers following the format of `value`.
4. `add`: when `value` is a table of numbers, `add` is passed the index that has turned from 0 to 1 if it exists
5. `rem`: when `value` is a table of numbers, `rem` is passed the index that has turned from 1 to 0 if it exists
6. `list`: when `value` is a table of numbers, list is a table of indicies in `value` which are > 0
