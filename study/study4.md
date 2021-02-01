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

one thing that's kinda wierd: the `step` value is saved in our sequencer. this means that even the sequence picks off where it left off, but for musical effectiveness you'll propbably want to load up start off on the first note every session. add this property to `step`:
```
persistent = false
```
done & done. `persistent` means "this affordance value will be saved" - it defaults to true for most, but not all, affordances. only persistent affordances will be updated on `init` too.

# playing the ivories

one of my favorite uses of the grid is a keyboard, mapping a particular scale to the x-axis and moving up an octave every row. let's start on that that:
```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

engine.name = "PolySub" -- polysynth engine
scale = { 0, 2, 4, 7, 9 } -- scale degrees in semitones
root = 440 * 2^(5/12) -- the d above middle a

n = nest_ {
    keyboard = _grid.momentary {
        x = { 1, #scale },
        y = { 1, 4 },
        level = { 4, 15 },
        action = function(self, value)
            print(value)
        end
    }
} :connect { g = grid.connect() }

function init() n:init() end
```
momentary is like toggle, but high only as long as your finger stays on the key - just right for our keyboard. the value getting printed currently looks much like toggle:
```
{
    { 0, 0, 0, 0, },
    { 0, 0, 1, 0, },
    { 0, 0, 0, 0, },
    { 0, 1, 0, 0, },
    { 0, 0, 0, 0, },
}
```
however, for our engine we need to send note on & off messages, not the held state of every key. fortunately, the grid action functions are provided with more info, should you need it. the full argument list looks like this:
```
action = function(self, value, time, delta, added, removed, list)
```
- `time`: the amount of time in seconds that an affordance is held before releasing.
- `delta`: may eiter represent the change in `value` or the change in time between sucessive interactions (in the case of momentary it's a change in time).
- `added`: the index of the last key to go high.
- `removed`: the index of the last key to go low.
- `list`: list of high indicies.

`add` and `rem` are what's needed for the keyboard - when `added` is sent we know to add a note, when `removed` is sent we remove one. we can generate the needed note ID & frequency requested by the engine using the `x` and `y` coordinates of `added or removed` and our specified root note & scale - the rest is just math. all together that looks like this:
```
action = function(self, value, t, d, added, removed)
    local key = added or removed
    
    local id = key.y * 7 + key.x -- a unique integer for this grid key

    local octave = key.y - 5
    local note = scale[key.x]
    local hz = root * 2^octave * 2^(note/12)

    if added then engine.start(id, hz)
    elseif removed then engine.stop(id) end
end
```
hit run & you've got yourself a little pentatonic player (oh, and if pentatonics aren't your thing you can go ahead and switch up that scale).

# continued (but actually it's the end now)

- part 1: [nested affordances](./study1.md)
- part 2: [the grid & multiples](./study2.md)
- part 3: [affordance overview](./study3.md)
- part 4: state & meta-affordances
