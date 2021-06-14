[_arc.affordance](#affordance) {
  - [n](#x)
  - [x](#x)
  - value
  - [lvl](#lvl)
  - [min](#min)
  - [max](#max)
  - [sens](#sens)
  - [wrap](#wrap)

}

[_arc.number](#number) {
  - ...
  - [cycle](#cycle)
  - [indicator](#indicator)
  
}

[_arc.control](#control) {
  - ...
  - [controlspec](#controlspec)
  - [min](#min)
  - [max](#max)
  - [step](#step)
  - [units](#units)
  - [quantum](#quantum)
  - [warp](#warp)
  
}

[_arc.option](#option) {
  - ...
  - [options](#options)
  - [min](#min)
  - [max](#max)
  - [include](#include)
  - [size](#size)
  - [margin](#margin)
  - [glyph](#glyph)

}

[_arc.key.affordance](#key) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)

}

_arc.key.momentary { ... }

_arc.key.trigger { ... }

_arc.key.toggle { ... }

# affordances

### affordance

a base affordance type for the `_arc` group - all other affordances in the group inherit from this type. the user may extend this type in order to define a custom affordance for arc i/o.

### number

a fractional number controlled by arc roatation, one full rotation of of the indicator is equal to the value of [`cycle`](#cycle). the [`range`](#range) of `value` may be fininite or infinite (`math.huge`).

### control

like the `paramset` "control" type, a number with musicaly convenient properties. a `controlspec` is used internally, which may be provided at init time rather than properties.

### option

an integer affordance with a "tab" style output or the ability to display user-defined glyphs for each value.

# properties

### n

the index of the ring to which an affordance will be mapped (single integer only).

### x

the led or range of leds to send output to. defaults to `{ 33, 32 }`, a full circle starting at 33.

### lvl

sets the brightness levels for the affordance. may be a single value, or a table of 2-3 values depending on the range of output levels present.

### sens

fraction specifing input sensitivity. the lower the number, the slower the change in `value`.

### min

minimum output value.

### max

maximum output value.

### wrap

a boolean value to specify whether to wrap back over the `range` boundaries.

### cycle

indicates the amount that `value` will be incrimented after a full cycle through `x`.

### indicator

width of the led indicator displayed.

### step

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### units

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### quantum

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### warp

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### options 

an integer option count

### include

an optional table of integers from 1 - `options`. integers not included are skipped over on arc deltas.

### size

the size of the option tab. a single number or a table of numbers per option.

### margin

space between each option tab.

### glyph

a table that, when present, specifies a brightness level per arc led rather than the `option` tab display. usuful when formatted as a pointer function in conjuction with special arguments `glyph = function(self, value, led_count) return {} end`.

