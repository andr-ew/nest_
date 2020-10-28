# types

[_grid.control](#_grid.control) {
  - [x](#x)
  - [y](#y)
  - [value](#v)
  - [lvl](#x)
  - [edge](#edge)
  - [count](#count)
  - [fingers](#fingers)
  - wrap
  - [action](#action)

}

[_grid.fill](#_grid.fader) { ... }

[_grid.value](#_grid.fader) { ... }

[_grid.fader](#_grid.fader) {
  - ...
  - [range](#range)
  
}

[_grid.trigger](#_grid.trigger) { ... }

[_grid.momentary](#_grid.momentary) { ... }

[_grid.toggle](#_grid.toggle) { ... }

[_grid.range](#_grid.toggle) { ... }

_grid.pattern { ... }

_grid.preset { ... }


### _grid.control

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

### _grid.fill

### _grid.value

### _grid.fader

### _grid.trigger

### _grid.momentary

### _grid.toggle

### _grid.range

# properties

### value

the control value. the format of value depends on the control type and the `x` and `y` dimentions. it is always either a number or a table of numbers - see types for details

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
