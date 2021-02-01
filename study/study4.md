# video

[https://www.youtube.com/watch?v=MagBGbhtZTY](https://www.youtube.com/watch?v=MagBGbhtZTY)

# remembering

let's jump back to study 2 - it's fun right ? did you make any neat sequences you like ? well if you did they are probably gone forever now, as with most fresh scripts everything is tossed to the ether upon loading another script or powering down. we call that collection of data being tossed the script's **state**. we can easily circumvent such limitations in the nest_.

add this to the bottom of the study 2 script (replacing the old `init` function):
```
function init()
    seq:load()
    seq:init()
    clock.run(count)
end

function cleanup()
    seq:save()
end
```
bloop up a nice sequence, rerun the script, aaaaaand ... bloop conitiued. easy. what happenind? check your `data/nest_/study2` folder. there's a lua file there, and in the file there's a big table (you can edit it, by the way). the `save` function called in the global cleanup function (which runs whenever the script ends) makes a big table with all the values from the `seq` nest and writes out a lua file for that table in the script's dedicated data folder. then `load` checks for that script, runs it if it's there, and plops those values into back into the nest. you'll want to make sure to load _before_ calling `seq:init()`, so the newly recalled values are pushed to the action functions. the first argument to both `load` and `save` is an integer specifying a file number to save or load, that way multiple files may be stored and used as a preset syetem (note this is entirelly seperate from the `pset` system reserved for `params`). if no arguments are present the number chosen is 0 - it's useful to use 0 as kind of a persistent state between script runs. 

one thing that's kinda wierd: the `step` value is saved. this means that even the sequence picks off where it left off, but for musical effectiveness you'll propbably want to load up start off on the first note every session. add this property to `step`:
```
persistent = false
```
done & done. persistent means "this affordance value will be saved" - it defaults to true for most, but not all, affordances. only persistent affordances will be updated on `init` too.

# playing the ivories

one of my favorite uses of the grid is a keyboard, mapping a particular scale to the x-axis and moving up an octave every row. let's do that.

# continued (but actually it's the end now)

- part 1: [nested affordances](./study1.md)
- part 2: [the grid & multiples](./study2.md)
- part 3: [affordance overview](./study3.md)
- part 4: state & meta-affordances
