`{.:}`

# nest_ (beta)

`nest_` is an object language and library for constructing user interface structures in lua for monome devices. 

it is a collection of common interface components (affordances) and nested object-oriented-ish heuristics that allow for expressive assemblage of user interfaces on monome grids, norns, and arcs, with arbitrary, automatable functionalities bound by the artist programmer.

```
nest_ {
    _affordance {
        property = 5,
        value = 1,
        action = function(self, value)
            dosomething(value)
        end
    }
}
```

currently in beta ! current documentation covers existing features, will continue to grow w/ progress over the next few months

# Demos

start here !

- [`demo`](demo.lua): demos of library affordances per device
- `twigs`: a musical demonstration, ditonic keyboard + pitched delays

# Studies

1. [nests of affordances](./study/study1.md)

2. [the grid module](./study/study2.md)

3. the norns interface

4. affordances controlling affordances

5. customization

# Docs

## Modules

the various types and interface buidling blocks of nestworld are split up into a growing collection files or `modules`. at the very least, the `core` and `norns` modules are required for use with norns. click the links to read on !


- [`nest_/core`](./doc/core.md)
- [`nest_/norns`](./doc/norns.md)
- [`nest_/grid`](./doc/grid.md)
- `nest_/arc`
- [`nest_/txt`](./doc/txt.md)


## Including

run `norns.fetch("https://github.com/andr-ew/nest_")` in the madien [repl](https://monome.org/docs/norns/maiden/#repl) to download this repo to your code folder

typically, it will make the most sense to include nest_ by copying the required module files into your script's `/lib/nest_` folder, including them like so:

```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'
```

alternatively, you can incude modules externally (`nest_` will be a dependency): `include 'nest_/lib/nest_/core'`
