# Nest_

`nest_` is an object language and library for building user interface structures on the monome norns sound computer

```
n = nest_ {
    control = _grid.toggle {
        x = { 1, 4 },
        y = 1,
        edge = 0,
        action = function(s, v, t)
            print("v")
            tab.print(v)
            print('t')
            tab.print(t)
         end
    }
} :connect { g = grid.connect() }
```

### [RELEASES](https://github.com/andr-ew/nest_/releases/)

# Docs
## Modules

- [`nest_/core`](./doc/core.md)
- `nest_/norns`
- [`nest_/grid`](./doc/grid.md)
- `nest_/arc`
- `nest_/txt`

the various types and interface buidling tools of nestworld are split up into a growing collection files or `modules` inside `lib/nest_`. at the very least, the `core` and `norns` modules are required for use with norns. click the links to read on !

## Including

typically, it will make the most sense to include nest_ by dropping the required module files into your script's `/lib/nest_` folder and including them like so:

```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'
```

alternatively, if this repo lives in your code folder, you can incude modules externally: `include 'nest_/lib/nest_/core'`
