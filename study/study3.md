# look around

studies 1 & 2 covered the essential basic techniques of nest_ structures. we measured the depth of a lake - now is a good time to step back and observe the width (though, I like to think of nest_ as a network of underwater caves).

the library affordances are split into three optional modules, each operating on specific hardware. here is an overview of each:

| module       | hardware | output domain | hardware key-value pairs | groups |
| ---          | ---      | ---    |---             | ---
| `grid` | grid | light | `g = grid.connect(n)` | `_grid` |
| `arc` | arc | light |`a = arc.connect(n)` | `_arc`, `_arc.key` |
| `txt` | keys, encoders, screen | text | `screen = screen, key = key, enc = enc` | `_txt.enc`, `_txt.key` |

in review:

- a module is included like this:
```
include "lib/nest_/<module>"
```
- hardware is connected to a nest like this (you can connect key-value pairs to one nest):
```
my_nest:connect {
    <key-value pairs>
}
```
- affordances from a module are created like this:
```
my_affordance = <group>.<affordance type> {
    --
}
```
you've already been doing this with `grid`, but now you have some formality to things ;)

# affordance types

rather than a long list of terms & behaviors, there are 9 affordance types - each utimately with seprate implimentations in every group that uses it - but some similarities overall. 

overview:

| type | value | descripton | `_grid` | `_arc` | `_arc.key` | `_txt.enc` | `_txt.key` |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `fill` | none | a static display | x | x | | | |
| `number` | integer or decimal | a point in space | x | x | | x | x |
| `control` | decimal | a number bound by an internal `controlspec` | x | x | | x | |
| `option` | decimal | an index in a range of options. should be rounded down before use. | | x | | x | x |
| `list` | decimal | an option that selects from a list of other affordances | | | | x | x |
| `range` | two integers | two numbers in a table, denoting a slice of a whole | x | | | | |
| `trigger` | 0 or 1 | an instantaneous bang, value is used only for display | x | | x | | x |
| `toggle` | integer | cycles forward through a list of numbers, but usually just 0 and 1 | x | | x | | x |
| `momentary` | 0 or 1 | becomes 1 on a rising edge, 0 on a falling edge | x | | x | | x |

(note in the case of `_grid`, `_txt.enc`, `_txt.key`, the value may be a table of numbers or a table of table of numbers)

# example

![docs](./img/study3-01.png)

# continued

- part 1: [nested affordances](./study1.md)
- part 2: [the grid & multiples](./study2.md)
- part 3: affordance overview
- part 4: [state & meta-affordances](./study4.md)
