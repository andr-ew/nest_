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
    --do the normal thing
end
```
delta, which will measure the time between sucsessive downstrokes, can be used as a tap tempo control.

`added`, `removed`, and `list` are only meaningful when `momentary` occupies more than one key. they provide an alternave view into `value`. `list` is a table of high indicies within `value`. `added` and `removed` show the most recent index that has been added or removed from `list`. this is useful in the case of polysynth engines or midi, which need note on & off messages rather than the full state of a keyboard. using these arguments, we can extend the example above into a simple polyphonic keyboard:
```
engine.name = "PolySub"
scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

n = nest_ {
    keyboard = _grid.momentary {
        x = { 1, #scale },
        y = 1,
        level = { 4, 15 },
        action = function(self, value, time, delta, added, removed)
            local key = added or removed
            local id = key -- a unique integer for this grid key

            local octave = -2
            local note = scale[key]
            local hz = root * 2^octave * 2^(note/12)

            if added then engine.start(id, hz)
            elseif removed then engine.stop(id) end
        end
    }
} :connect { g = grid.connect() }
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

one thing that's kinda wierd: the `step` value is saved in our sequencer. this means that even the sequence picks off where it left off, but for musical effectiveness you'll propbably want to start off on the first step every fresh session. add this property to `step`:
```
persistent = false
```
`persistent` means "this affordance value will be saved" - it defaults to true for most, but not all, affordances. only persistent affordances will be updated on `init`.


# patterns in space

we can use these state saving functions within a script as well - there's two affordance-wide functions for this, let's try it out with a `toggle`:
```
n = nest_ {
    t = _grid.toggle {
        x = { 1, 5 },
        y = 1,
        level = { 4, 15 },
        action = function(self, value)
            print(value)
        end
    }
} :connect { g = grid.connect() }
```
create a pattern of lights - to save it for later, run `past = n.t:get()` in the REPL. create a new pattern, then run `n.t:set(past)` to return to the past.

we can use these two functions inside another affordance as the foundation of a touchable preset system. the `grid` module comes with a shortcut for this:
```
n = nest_ {
    t = _grid.toggle {
        x = { 1, 5 },
        y = 1,
        level = { 4, 15 },
        action = function(self, value)
            print(value)
        end
    },
    preset = _grid.preset {
        x = { 1, 5 },
        y = 2,
        target = function() return n.t end
    }
} :connect { g = grid.connect() }
```
`preset` is like `number` but each value represents a preset slot - hitting a key either opens up a new slot for modification or recalls a preset. try creating a unique toggle pattern in every preset slot & play around with preset recall.

we call `preset` a **meta-affordance** because unlike other other affordances, the `action` function comes predefined - it's just used to observe and modify other affordances. `target` is the state to observe - it can be an affordance or a nest of affordances (all of their values will be pulled into preset storage). if we don't want a partuclar affordance or nest to be affected by meta-affordances, we can set `observable = false`. in the snippet above, it seems like `target = n.t` would be sensible, but in practice, lua creates nested tables from the inside out so we get an error saying `n` is nil. a function returning our desired object is a simple workaround.

# patterns in time

there is one other meta-affordance bundled in `grid`. `pattern` records input on a target and plays it back in a loop - one of the defining features of apps like earthsea and mlr. let's give it a whirl with the poly keyboard example:
```
engine.name = "PolySub"
scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

n = nest_ {
    keyboard = _grid.momentary {
        x = { 1, #scale },
        y = 1,
        level = { 4, 15 },
        action = function(self, value, time, delta, added, removed)
            local key = added or removed
            local id = key -- a unique integer for this grid key
            
            local octave = -2
            local note = scale[key]
            local hz = root * 2^octave * 2^(note/12)

            if added then engine.start(id, hz)
            elseif removed then engine.stop(id) end
        end
    },
    pattern = _grid.pattern {
        x = { 1, 5 },
        y = 2,
        target = function() return n.keyboard end
    }
} :connect { g = grid.connect() }
```
`pattern` is like a toggle with many states & all five keys are unique record/playback buttons. the first press initiates recording (dim blinking state), then once playback is happening it turns into a play/pause toggle. play around with creating a few asycnronous loops on your tiny keyboard. holding and releasing a loop key will clear it - you can also double tap to overdub on top of a playing pattern.

five patterns playing at once might be a lot to handle for this smol synthesizer, so we might consider using a property to limit the polyphony of playback in the `pattern` affordance:
```
count = 1
```
now only one pattern will play at a time (all of the grid afforances have a `count` property, by the way). this is useful for creating a few alternating musical measures that can be switched out by hand. 

along the way you might've noticed that some hung notes might be happening when switching patterns or pausing. we can use the `stop` function in our `pattern` to clear things out in these cases (`clear` is handy reset function specific to `momentary`):
```
stop = function()
    n.keyboard:clear()
    engine.stopAll()
end
```

oh and if you weren't already wondering, you can absolutely pattern record preset recall, and store patterns in presets. both are also `persistent` by default and fully compatible with the `load`/`save` feature.

# value of a value

so far we've been thinking about affordances as tables with internal data (`value`) and a function that runs whenever the data changes (`action`). that's been a useful model for our small study scripts thus far, but generally when working on a full script you'll have data all over the place, not just in your nest. maybe you have a variable:
```
foo = 10
```
if you need a `_grid.number` to update `foo`, that's easy enough:
```
n = nest_ {
    foo_controller = _grid.number {
        x = { 1, 16 }, 
        y = 1,
        action = function(s, v) foo = v end
    }
} :connect { g = grid.connect() }
```
but what if something else, somewhere else, changes the value of `foo` ? nothing will neccesarily explode or malfunction, but the `value` shown on the grid won't be updated to its true value - `foo` (even if you call `grid_redraw()`, which forces `nest_` to refresh the grid). 

you could make another function to update `foo_contoller` manually:
```
function call_this_when_foo_changes()
    n.foo_controller.value = foo
    n.foo_controller:update()
end
```
but this gets pretty circular & difficult to mainatin (imagine having 30 different foos & affordances). of course, there's a better way ! remember how any property can be a function ? the same goes for `value`:
```
n = nest_ {
    foo_controller = _grid.number {
        x = { 1, 16 }, 
        y = 1,
        value = function() return foo end,
        action = function(s, v) foo = v end
    }
} :connect { g = grid.connect() }
```
this time, we've assigned `value` to a function which retrieves external data and returns it. so whenever the grid is drawn, it'll look straight to `foo` rather than storing a separate internal state.

in norns scripts, it's very common to use the `params` sytem to store data & actions. so, if we want a grid affordance that's _bound_ to a "foo" parameter, we can use a value function:
```
foo_controller = _grid.control {
    x = { 1, 16 }, 
    y = 1,
    controlspec = params:lookup_param('foo').controlspec,
    value = function() return params:get('foo') end,
    action = function(s, v) params:set('foo', v) end
}
```
since `_grid.control` takes a `controlspec` property we can steal that from the param as well. now any changes on the grid will update the param and any changes in the param will update the grid (note the param action will need to call `grid_redraw()` for changes to be instantly visible). the above snippet tends to be so useful that nest ships with a shortcut _binder method_ called `param`. we can rewrite the above lines as:
```
foo_controller = _grid.control {
    x = { 1, 16 }, 
    y = 1
} :param('foo')
```
every affordance type has set param types it can bind to automatically. `_grid.control` natually can only bind to control params. just like before, `action` will be overwritten by param binding - instead, actions should occur in the `'foo'` param action function. also note that bound afforcances are non-persistent. again, you should do things the params way with `params:read()` / `params:write()`.

# example

our fourth & final study script is a pretty complete and playable synth with a grid keyboard, a delay, pattern recorders, and presets. we're using the `control` affordance on both grid and norns and binding them to existing `PolySub` and `halfsecond` params. things are grouped so that the pattern recorders can target both the keyboard and preset recall.

```
include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'
include 'lib/nest/txt'

polysub = include 'we/lib/polysub'
delay = include 'awake/lib/halfsecond'
local cs = require 'controlspec'

scale = { 0, 2, 4, 7, 9 }
root = 440 * 2^(5/12) -- the d above middle a

engine.name = 'PolySub'

polysub.params()
delay.init()
    
synth = nest_ {
    grid = nest_ {
        pattern_group = nest_ {
            keyboard = _grid.momentary {
                x = { 1, #scale }, -- notes on the x axis
                y = { 2, 8 },-- octaves on the y axis
                
                action = function(self, value, t, d, added, removed)
                    local key = added or removed
                    local id = key.y * 7 + key.x -- a unique integer for this grid key
                    
                    local octave = key.y - 5
                    local note = scale[key.x]
                    local hz = root * 2^octave * 2^(note/12)
                    
                    if added then engine.start(id, hz)
                    elseif removed then engine.stop(id) end
                end
            },
            control_preset = _grid.preset {
                y = 1, x = { 9, 16 },
                target = function(self) return synth.grid.controls end
            }
        },
        pattern = _grid.pattern {
            y = 1, x = { 1, 8 },
            target = function(self) return synth.grid.pattern_group end,
            stop = function()
                synth.grid.pattern_group.keyboard:clear()
                engine.stopAll()
            end
        },
    
        -- synth controls
        controls = nest_ {
            shape = _grid.control {
                x = 9, y = { 2, 8 },
            } :param('shape'),
            timbre = _grid.control {
                x = 10, y = { 2, 8 },
            } :param('timbre'),
            noise = _grid.control {
                x = 11, y = { 2, 8 },
            } :param('sub'),
            hzlag = _grid.control {
                x = 12, y = { 2, 8 },
            } :param('noise'),
            cut = _grid.control {
                x = 13, y = { 2, 8 },
            } :param('cut'),
            attack = _grid.control {
                x = 14, y = { 2, 8 },
            } :param('ampatk'),
            sustain = _grid.control {
                x = 15, y = { 2, 8 },
            } :param('ampsus'),
            release = _grid.control {
                x = 16, y = { 2, 8 },
            } :param('amprel')
        }
    },
    
    -- delay controls
    screen = nest_ {
        delay = _txt.enc.control {
            x = 2, y = 16, 
            n = 1,
        } :param('delay'),
        rate = _txt.enc.control {
            x = 2, y = 44, 
            n = 2
        } :param('delay_rate'),
        feedback = _txt.enc.control {
            x = 64, y = 44,
            n = 3,
        } :param('delay_feedback'),
    }
}

synth.grid:connect {
    g = grid.connect()
}

synth.screen:connect {
    screen = screen,
    key = key,
    enc = enc
}

function init()
    synth:load()
    params:read()
    synth:init()
    params:bang()
end

function cleanup()
    synth:save()
    params:write()
end
```

# challenge

- reference `polysub.lua` to map alternate synth controls based on your tastes
- rearrange things to have preset control over patterns rather than pattern control over presets (I think I like this variant better)
- limit `pattern.count` to one and add another pattern recorder to record pattern switching (like a meta-sequencer)

# continued (but actually it's the end now)

- part 1: [nested affordances](./study1.md)
- part 2: [multiplicity](./study2.md)
- part 3: [affordance overview](./study3.md)
- part 4: state & meta-affordances
