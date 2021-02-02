# video

[https://www.youtube.com/watch?v=MagBGbhtZTY](https://www.youtube.com/watch?v=MagBGbhtZTY)

# metadata

in the grid demo in the last study script, you might've seen some extra data points being printed beyond `value`. grid action functions receive additional arguments - let's touch base on what those are and how they can be used in the case of `momentary`:
 ```
 n = nest_ {
    keyboard = _grid.momentary {
        x = { 1, 5 },
        y = 1,
        level = { 4, 15 },
        action = function(self, value, time, delta, added, removed, list)
            print('1. self')
            print('2. value: ' .. tostring(value))
            print('3. time: ' .. tostring(time))
            print('4. delta: ' .. tostring(delta))
            print('5. added: ' .. tostring(added))
            print('6. removed: ' .. tostring(removed))
            print('7. list: ' .. tostring(list))
        end
    }
} :connect { g = grid.connect() }
```
`value` should look pretty familiar coming in from `toggle`: a table of 1's and 0's, this time only high as long as keys are held. here's a quick overview of the rest of the arguments:

- `time`: the amount of time in seconds that an affordance is held before releasing.
- `delta`: may eiter represent the change in `value` or the change in time between sucessive interactions (in the case of momentary, it's a change in time).
- `added`: the index of the last key to go high.
- `removed`: the index of the last key to go low.
- `list`: list of high indicies.

`time` can be useful for imparting useful dynamics into keypresses (such as control of a slew setting), even with the grid's lack of velocity input. it can also be used with a bit of logic to create an alernate hold function, like this:
```
if time > 0.2 then
    --clear a loop
else
    --do the normall thing
end
```
delta, which will measure the time between sucsessive downstrokes, can be used as a tap tempo control.

`added`, `removed`, and `list` are only meaningful when `momentary` occupies more than one key. they provide an alternave view into `value`. `list` is a table of high indicies within `value`. `added` and `removed` show the most recent index that has been added or removed from `list`. this is useful in the case of polysynth engines or midi, which need note on & off messages rather than the full state of a keyboard. using these arguments, we can extend the example above into a simple polyphonic keyboard:
```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

engine.name = "PolySub"
scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

n = nest_ {
    keyboard = _grid.momentary {
        x = { 1, #scale },
        y = { 1, 4 },
        level = { 4, 15 },
        action = function(self, value)
            local key = added or removed
    
            local id = key.y * 7 + key.x -- a unique integer for this grid key

            local octave = key.y - 5
            local note = scale[key.x]
            local hz = root * 2^octave * 2^(note/12)

            if added then engine.start(id, hz)
            elseif removed then engine.stop(id) end
        end
    }
} :connect { g = grid.connect() }

function init() n:init() end
```


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

one thing that's kinda wierd: the `step` value is saved in our sequencer. this means that even the sequence picks off where it left off, but for musical effectiveness you'll propbably want to load up start off on the first note every session. add this property to `step`:
```
persistent = false
```
done & done. `persistent` means "this affordance value will be saved" - it defaults to true for most, but not all, affordances. only persistent affordances will be updated on `init` too.

# patterns of space

# patterns of time



# continued (but actually it's the end now)

- part 1: [nested affordances](./study1.md)
- part 2: [multiplicity](./study2.md)
- part 3: [affordance overview](./study3.md)
- part 4: state & meta-affordances
