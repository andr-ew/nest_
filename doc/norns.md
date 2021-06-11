[_enc.affordance](#affordance) {
  - [n](#n)
  
}

[_enc.number](#number) {
  - [n](#n)
  - [min](#min)
  - [max](#max)
  - [wrap](#wrap)
  - [inc](#inc)
  
}

[_enc.control](#control) {
  - [n](#n)
  - [controlspec](#controlspec)
  - [min](#min)
  - [max](#max)
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
  - [min](#min)
  - [max](#max)
  - [wrap](#wrap)
  - [inc](#inc)
  
}

[_key.option](#option) {
  - [n](#n)
  - [edge](../doc/grid.md#edge)
  - [wrap](#wrap)
  - [options](#options)
  - [inc](#inc)
  
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

[_screen](#screen) {}

# affordances

### affordance

a base affordance type for the `_enc` and `_key` groups - all other affordances in the group inherit from this type. the user may extend this type in order to define a custom affordance that responds to the relevant input.

### number

an integer or fractional number.

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

### screen

the empty screen drawing affordance. define your own `redraw` handler for custom screen drawing. add `input = _screen.input{ redraw = function() end }` to an affordance for a custom screen UI.

# properties

### n

the index of the encoder or key to which an affordance will be mapped. assigning a table value to `n` will map to multiple inputs, either assigning a table to `value` or altering behavior (see [options](#options) and [inc](#inc))

### max

max limit of `value`. use `math.huge` for no limit.

### min

min limit of `value`. use `-math.huge` for no limit.

### wrap

a boolean value to specify whether to wrap back over the `mix`/`max` boundaries

### inc

specify how much `value` is incrimented on tick (delta/keypress). when `n` is a table, one and two specify an incriment of -1 and +1 which is multiplied by `inc`

### controlspec

a [`controlspec`](http://norns.local/doc/classes/controlspec.html#controlspec:new) instance which may be provided in place of `min`, `max`, `step`, `units`, `quantum`, `warp`. 

### step

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### units

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### quantum

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### warp

see http://norns.local/doc/classes/controlspec.html#controlspec:new

### options

a table of dispay values for the `option` type. when `n` is a table for `_enc.option`, `options` is treated on a nested matrix of tables, with two encoders specifying x and y indicies within the matrix
