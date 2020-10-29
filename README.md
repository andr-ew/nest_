# nest_

`nest_` is an object language and library for building user interface structures in lua for monome devices

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

currently in beta ! provided documentation matches current features, will continue to grow w/ progress over the next few months

### [RELEASES](https://github.com/andr-ew/nest_/releases/)

# Studies

1. [nests of controls](./study/study1.md)

2. [the grid module](./study/study2.md)

3. the txt module

4. controls controlling controls

5. mixing inputs

# Docs

## Modules

the various types and interface buidling blocks of nestworld are split up into a growing collection files or `modules`. at the very least, the `core` and `norns` modules are required for use with norns. click the links to read on !


- [`nest_/core`](./doc/core.md)
- `nest_/norns`
- [`nest_/grid`](./doc/grid.md)
- `nest_/arc`
- `nest_/txt`


## Including

typically, it will make the most sense to include nest_ by dropping the required module files into your script's `/lib/nest_` folder and including them like so:

```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'
```

alternatively, if this repo lives in your code folder, you can incude modules externally: `include 'nest_/lib/nest_/core'`

# Examples

- [various](https://github.com/andr-ew/nest_/tree/master/examples)
- [ndls (full app)](https://github.com/andr-ew/ndls/blob/master/ndls.lua)
- [brds (full app)](https://github.com/andr-ew/brds/blob/main/brds.lua)
