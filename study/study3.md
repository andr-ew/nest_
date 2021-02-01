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

rather than a long list of terms & behaviors, there are n affordance types - each utimately with seprate implimentations in every group - but some similarities overall. overview:

| type | value | descripton | `_grid` | `_arc` | `_arc.key` | `_txt.enc` | `_txt.key` |
| --- | --- | --- | --- | --- | --- | --- | --- |
| fill | | | | | | | |
| number | | | | | | | |
| control | | | | | | | |
| option | | | | | | | |
| list | | | | | | | |
| range | | | | | | | |
| trigger | | | | | | | |
| toggle | | | | | | | |
| momentary | | | | | | | |

# example

![docs](./img/study3-01.png)

# continued

- part 1: [nested affordances](./study1.md)
- part 2: [the grid & multiples](./study2.md)
- part 3: affordance overview
- part 4: [state & meta-affordances](./study4.md)
