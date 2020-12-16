# types

[_txt.affordance](#affordance) {
  - [font_face](#font_face)
  - [font_size](#font_size)
  - [x](#x)
  - [y](#y)
  - [lvl](#lvl)
  - [border](#border)
  - [fill](#fill)
  - [size](#size)
  - [padding](#padding)
  - [margin](#margin)
  - [flow](#flow)
  - [align](#align)
  - [line_wrap](#line_wrap)
  - [selection](#selection)
  - [scroll_window](#scroll_window)
  - [scroll_focus](#scroll_focus)
  - [font_headroom](#font_headroom)
  - [font_leftroom](#font_leftroom)
  
}



[_txt.label](#affordance) {
  - ...
  
}

[_txt.enc.number](#number) {
  - ...
  - [n](../doc/norns.md#n)
  - [range](../doc/norns.md#range)
  - [wrap](../doc/norns.md#wrap)
  
}

[_txt.enc.control](#control) {
  - ...
  - [n](#n)
  - [controlspec](../doc/norns.md#controlspec)
  - [range](../doc/norns.md#range)
  - [step](../doc/norns.md#step)
  - [units](../doc/norns.md#units)
  - [quantum](../doc/norns.md#quantum)
  - [warp](../doc/norns.md#warp)
  - [wrap](../doc/norns.md#wrap)
  
}

[_txt.enc.option](#option) {
  - ...
  - [n](../doc/norns.md#n)
  - [wrap](../doc/norns.md#wrap)
  - [options](../doc/norns.md#options)
  
}

[_txt.key.number](#number) {
  - ...
  - [n](../doc/norns.md#n)
  - [edge](../doc/grid.md#edge)
  - [range](../doc/norns.md#range)
  - [wrap](../doc/norns.md#wrap)
  - [inc](../doc/norns.md#inc)
  
}

[_txt.key.option](#option) {
  - ...
  - [n](../doc/norns.md#n)
  - [edge](../doc/grid.md#edge)
  - [wrap](../doc/norns.md#wrap)
  - [options](../doc/norns.md#options)
  - [inc](../doc/norns.md#inc)
  
}

[_txt.key.trigger](#trigger) {
  - ...
  - [n](../doc/norns.md#n)
  - [edge](../doc/grid.md#edge)
  - [fingers](../doc/grid.md#fingers)
  - [blinktime](../doc/grid.md#blinktime)
  
}

[_txt.key.momentary](#momentary) {
  - ...
  - [n](../doc/norns.md#n)
  - [edge](../doc/grid.md#edge)
  - [fingers](../doc/grid.md#fingers)
  
}

[_txt.key.toggle](#toggle) {
  - ...
  - [n](../doc/norns.md#n)
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

# properties
