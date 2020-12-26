# types

[_arc.affordance](#affordance) {
  - [n](#x)
  - [x](#x)
  - value
  - [lvl](#lvl)
  - [range](#range)
  - [sens](#sens)
  - [wrap](#wrap)

}

[_arc.number](#number) {
  - ...
  - [cycle](#cycle)
  - [inc](#inc)
  - [indicator](#indicator)
  
}

[_arc.control](#control) {
  - ...
  - [controlspec](#controlspec)
  - [range](#range)
  - [step](#step)
  - [units](#units)
  - [quantum](#quantum)
  - [warp](#warp)
  
}

[_arc.option](#option) {
  - ...
  - [options](#options)
  - [range](#range)
  - [include](#include)
  - [size](#size)
  - [margin](#margin)
  - [glyph](#glyph)

}

[_arc.key.affordance](#key) {
  - [n](#n)
  - [edge](#edge)

}

_arc.key.momentary { ... }

_arc.key.trigger { ... }

_arc.key.toggle { ... }


### affordance

a base affordance type for the `_arc` group - all other affordances in the group inherit from this type. the user may extend this type in order to define a custom affordance for arc i/o.

### number

a fractional number controlled by arc roatation, one full rotation of of the indicator is equal to the value of [`cycle`](#cycle). the [`range`](#range) of `value` may be fininite or infinite (`math.huge`).

### control

like the `paramset` "control" type, a number with musicaly convenient properties. a `controlspec` is used internally, which may be provided at init time rather than properties.

### option

an integer affordance with a "tab" style output or the ability to display user-defined glyphs for each value.

# properties

### step

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### units

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### quantum

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### warp

see http://norns.local/doc/classes/controlspec.html#controlspec:new
