# nest_

![logo](study/img/nest_.png)

nest is a language of touch for objects by monome

**discussion thread: [https://llllllll.co/t/nest](https://llllllll.co/t/nest)**

nest helps you build a touchable user interface for a norns script, and provides the tools to hook up that interface to whatever sound engine or musical process you’d like to interact with (a synth engine, a softcut looper,  a lua sequencer, crow voltages & i2c). you're welcome to think about nest as a full-blown library, a (not really)markup language, [react](https://reactjs.org/) for monome, or a maiden-scriptable application in the vein of teletype's [grid ops](https://github.com/scanner-darkly/teletype/wiki/GRID-INTEGRATION).

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

# compatibility

nest is a tool for the [monome norns](https://monome.org/) ecosystem

while a norns by itself is technically the only requirement for nest (see the txt module), it tends to prove more useful when building interfaces with lots of input (grid, grid + norns, or grid + arc + norns). norns after all, just has three keys and two encoders, so many musical ideas can be expressed cleanly without this sort of system, and you get some more flexibility as a bonus (see the examples in [norns studies](https://monome.org/docs/norns/scripting/), if you haven’t already). if you want to get a feel for the sort of textual norns interfaces the txt module can be used for, feel free to skip ahead to study 3.

# studies

start here! the studies assume only basic knowledge of lua and the norns system (see [norns studies](https://monome.org/docs/norns/scripting/) if you want to get your bearings first). 

get the study scripts by installing `nest_` in the maiden project manager. feel free to play around with the scriptss on your grid before digging in to the rest! (if you’re using norns gridless, see the note above on compatibility).

1. [nested affordances](./study/study1.md)

2. [multiplicity](./study/study2.md)

3. [affordance overview](./study/study3.md)

4. [state & meta-affordances](./study/study4.md)

# docs

## modules

the various types and interface buidling blocks of nestworld are split up into a collection files/modules. at the very least, the `core` and `norns` modules are required for use with norns. click the links to read up on the full details of each module and the affordances contained.


- [`nest/grid`](./doc/grid.md)
- [`nest/arc`](./doc/arc.md)
- [`nest/norns`](./doc/norns.md)
- [`nest/txt`](./doc/txt.md)
- [`nest/core`](./doc/core.md)


## including

typically, it will make the most sense to include nest by copying the required module files into your script's `/lib/nest` folder, including them like so:

```
include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'
include 'lib/nest/txt'
```

alternatively, you can incude modules externally (watch those underscores!):
```
include 'nest_/lib/nest/core'
...
```
you & other users will need to install nest_ from maiden
