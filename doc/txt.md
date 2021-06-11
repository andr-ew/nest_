[_txt.affordance](#affordance) {
  - [font_face](#font_face)
  - [font_size](#font_size)
  - [x](#x)
  - [y](#y)
  - [label](#label)
  - [formatter](#formatter)
  - [step](#step)
  - [lvl](#lvl)
  - [border](#border)
  - [fill](#fill)
  - [size](#size)
  - [padding](#padding)
  - [margin](#margin)
  - [flow](#flow)
  - [align](#align)
  - [line_wrap](#line_wrap)
  - [selected](#selected)
  - [scroll_window](#scroll_window)
  - [scroll_focus](#scroll_focus)
  - [font_headroom](#font_headroom)
  - [font_leftroom](#font_leftroom)
  
}

[_txt.label](#labeltype) {
  - ...
  
}

[_txt.enc.number](#number) {
  - ...
  - [n](../doc/norns.md#n)
  - [min](../doc/norns.md#min)
  - [max](../doc/norns.md#max)
  - [wrap](../doc/norns.md#wrap)
  - [inc](../doc/norns.md#inc)
  
}

[_txt.enc.control](#control) {
  - ...
  - [n](#n)
  - [controlspec](../doc/norns.md#controlspec)
  - [min](../doc/norns.md#min)
  - [max](../doc/norns.md#max)
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

[_txt.enc.list](#list) {
  - ...
  - [items](#items)
  - [wrap](../doc/norns.md#wrap)
  
}

[_txt.key.number](#number) {
  - ...
  - [n](../doc/norns.md#n)
  - [edge](../doc/grid.md#edge)
  - [min](../doc/norns.md#min)
  - [max](../doc/norns.md#max)
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

[_txt.key.list](#list) {
  - ...
  - [items](#items)
  - [edge](../doc/grid.md#edge)
  - [wrap](../doc/norns.md#wrap)
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

# affordances

### affordance

a base affordance type for the `_txt` group - all other affordances in the group inherit from this type and share the display properties. the user may extend this type in order to define a custom affordance with text output.

### label(type)

an output only text type, `value` is displayed and may be a string, a table of strings, or a table of tables of strings. useful for evaluating the various display properties. each string provided will be it's own "text block" with positioning and sizing set based on a combination of multiple proeries in the parent affordance (think "norns css").

### number

an integer or fractional number. [`label`](#label) defaults to [`k`](../doc/core.md#k).

### control

like the `paramset` "control" type, a number with musicaly convenient properties. a `controlspec` is used internally, which may be provided at init time rather than properties. [`label`](#label) defaults to [`k`](../doc/core.md#k).

### option

like the `paramset` "option" type, a list of strings or numbers to be iterated through. the `value` property stored is the index of the active option (the value at this index is returned as the third argument to `action`). all options are displayed, with the index `value` set to the [`selected`](#selected) property. useful in conjunction with the [`scroll_window`](#scroll_window) and [`scroll_focus`](#scroll_focus) properties.

### list

like option, but may display a list of other affordance types in the `_txt` group, enabling only the object at the `selected` index. think "params menu" but `nest_`y.

### trigger

an affordance that blinks for `blinktime` seconds and runs `action` on keypress. [`selected`](#selected) is set to the high indicies of `value`. [`label`](#label) is the displayed text, which defaults to [`k`](../doc/core.md#k).

### momentary

a "held" button where `value` goes high where a key is depressed, low where a key is released. [`selected`](#selected) is set to the high indicies of `value`. [`label`](#label) is the displayed text, which defaults to [`k`](../doc/core.md#k).

### toggle

a button where `value` toggles between high and low on a keypress. if `lvl` has a table length greater than two, a `toggle` button will cycle forward through those brightness values. [`selected`](#selected) is set to the high indicies of `value`. [`label`](#label) is the displayed text, which defaults to [`k`](../doc/core.md#k).

# properties

### font_face

a number indicating the font face.

### font_size

a number indicating the font size.

### x

the x component of the text position. this may be:
- a single number, to specify where a text group starts from on this axis (alignment)
- a table with two values, to specify where a text group begins and ends on this axis (justified)
- a table of tables, to specify exact boundaries for each string in the text group on this axis (manual placement)

### y

the y component of the text position. this may be:
- a single number, to specify where a text group starts from on this axis (alignment)
- a table with two values, to specify where a text group begins and ends on this axis (justified)
- a table of tables, to specify exact boundaries for each string in the text group on this axis (manual placement)

### label

a label to be displayed for input types. defaults to [`k`](../doc/core.md#k). set `label = false` to remove the label.

### formatter

a function that takes text as an argument & returns transformed text.

### step

displayed number values are rounded down to this division (default is 0.01)

### lvl

bightness level of the text to display.

### border

brightness level of the text box border. 0 for no border.

### fill

brightness level of the text box fill. 0 for no fill.

### size

a specifies a static width and height for the text box. a table of two sets width & height independently. the flag `'auto'` spefifies that an axis should be sized automatically.

### padding

the padding space between text and box edges for an auto-sized box.

### margin

the space between multiple text boxes.

### flow

specifies the axis over which a text group will flow. either `'x'` or `'y'`.

### align

sets position alignment for a text group axis when x and/or y is a single number. may take the form:
- `'left'`, `'center'` or `'right'`
- `{ ['left' / 'center' / 'right'] , ['top' / 'bottom' / 'center'] }`

### line_wrap

specifies a single line of a text group to wrap to the next line after this number of strings has been placed on the line.

### selected

specifies an index or a table of indicies to be "selected" within a text group. for the properties `lvl`, `border`, `fill`, `font_face`, `font_size`, a table of two values my be provided, the first of which correlates to an unselected item, the second for a selected. this is mostly set by objects internally, see [types](#types).

### scroll_window

when selection is used, specifies a number of text items to scroll through. useful for `option` or `list` affordances with many items.

### scroll_focus

specifies a boundary within the window the selection will move across before scrolling. either a single index or a table of min/max boundaries.
