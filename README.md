`{.:}`

# nest_

nest_ is a language of touch for objects by monome

nest_ helps you build a touchable user interface for a norns script, and provides the tools to hook up that interface to whatever sound engine or musical process you’d like to interact with (a synth engine, a softcut looper,  a lua sequencer, crow voltages & i2c). you're welcome to think about nest as a full-blown library, a markup language, or a maiden-scriptable application in the vein of [grid ops](https://github.com/scanner-darkly/teletype/wiki/GRID-INTEGRATION).

it works by splitting up an interface (grid, arc, or norns itself) into any number of lego pieces called **affordances**, each with a unique **value** and unique behaviors configured through **properties**. these lego blocks can then be bound to your musical process using custom **action functions** (much like the params system). affordances are organized inside special tables called **nests** which help group your affordances and allow them to communicate with each other and with the hardware itself. a basic snippet of nest code might look a bit like this:

```
nest_ {
    my_affordance = _affordance {
        property = 5,
        value = 1,
        action = function(self, value)
            engine.do_something_with(value)
        end
    }
}
```

# Compatibility

nest is a tool for the [monome norns](https://monome.org/) ecosystem

while a norns by itself is technically the only requirement for nest (see the txt module), it tends to prove more useful when building interfaces with lots of input (grid, grid + norns, or grid + arc + norns). norns after all, just has three keys and two encoders, so many musical ideas can be expressed cleanly without this sort of system (see the examples in [norns studies](https://monome.org/docs/norns/scripting/), if you haven’t already). if you want to get a better idea of the sort of interface the txt module can be used for by itself, feel free to skip ahead to study 3.

# Studies

start here! the studies assume only basic knowledge of lua and the norns system (see [norns studies](https://monome.org/docs/norns/scripting/) if you want to get your bearings first). in 5 steps, we’ll work towards building a playable, earthsea-like synth for the grid. here it is in action:

[https://www.youtube.com/watch?v=MagBGbhtZTY](https://www.youtube.com/watch?v=MagBGbhtZTY)

feel free to play around with studies 3 & 5 on your grid before digging in to the rest! (if you’re using norns gridless, see the note above on compatibility).

1. [nested affordances](./study/study1.md)

2. [the grid & multiples](./study/study2.md)

3. affordance demo

4. state & meta-affordances

5. making a script

get the study scripts by installing nest_ in the maiden project manager.

# Docs

## Modules

the various types and interface buidling blocks of nestworld are split up into a growing collection files or `modules`. at the very least, the `core` and `norns` modules are required for use with norns. click the links to read up on !


- [`nest_/grid`](./doc/grid.md)
- [`nest_/arc`](./doc/arc.md)
- [`nest_/norns`](./doc/norns.md)
- [`nest_/txt`](./doc/txt.md)
- [`nest_/core`](./doc/core.md)


## Including

typically, it will make the most sense to include nest_ by copying the required module files into your script's `/lib/nest_` folder, including them like so:

```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'
```

alternatively, you can incude modules externally (`nest_` will be a dependency): `include 'nest_/lib/nest_/core'`
