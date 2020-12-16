# types

[_enc.affordance](#affordance) {
  - [n](#n)
  
}

[_enc.number](#number) {
  - [n](#n)
  - [wrap](#wrap)
  
}

[_enc.control](#control) {
  - [n](#n)
  - [controlspec](#controlspec)
  - [range](#range)
  - [step](#step)
  - [units](#units)
  - [quantum](#quantum)
  - [warp](#warp)
  - [wrap](#wrap)
  
}

[_enc.option](#option) {
  - [n](#n)
  - [wrap](#wrap)
  - [options](#options)
  
}

[_key.affordance](#affordance) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  
}

[_key.number](#number) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  - [wrap](#wrap)
  - [inc](#inc)
  -
  
}

[_key.option](#option) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  - [wrap](#wrap)
  - [options](#options)
  
}

[_key.trigger](#trigger) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  - [fingers](../doc/grid.md#fingers)
  - [blinktime](../doc/grid.md#blinktime)
  
}

[_key.momentary](#momentary) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  - [fingers](../doc/grid.md#fingers)
  
}

[_key.toggle](#toggle) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  - [fingers](../doc/grid.md#fingers)
  
}

### affordance

a base affordance type for the `_enc` and `_key` groups - all other affordances in the group inherit from this type. the user may extend this type in order to define a custom affordance that responds to the relevant input.

### number

like the `paramset` "number" type, an integer number

### control

like the `paramset` "control" type, a number with musicaly convenient properties. a `controlspec` is used internally, which may be provided at init time rather than properties

### option

like the `paramset` "option" type, a list of strings or numbers to be iterated through. the `value` property stored is the index of the active option (the value at this index is returned as the third argument to `action`)

### trigger

an affordance that blinks for `blinktime` seconds and runs `action` on keypress.

### momentary

a "held" button where `value` goes high where a key is depressed, low where a key is released.

### toggle

a button where `value` toggles between high and low on a keypress. if `lvl` has a table length greater than two, a `toggle` button will cycle forward through those brightness values.

# methods

