# Nest_

`nest_` is an object language and library for building user interface structures on the monome norns sound computer

### [RELEASES](https://github.com/andr-ew/nest_/releases/)

# Docs
## Modules

- [`nest_/core`](./doc/core.md)
- [`nest_/grid`](./doc/grid.md)
- `nest_/arc`
- `nest_/txt`

## Including

typically, it will make the most sense to include nest_ by dropping the required module files into your script's `/lib/nest_` folder and including them like so:

```
include 'lib/nest_/norns' -- the core module, formatted for norns
include 'lib/nest_/grid'
include 'lib/nest_/txt'
```
