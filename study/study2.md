# video

[https://www.youtube.com/watch?v=8rI3b7ZaqlE](https://www.youtube.com/watch?v=8rI3b7ZaqlE)

# stretching

let's jump back to our number example:
```
n = nest_ {
    light = _grid.number {
        x = { 1, 5 },
        y = 1,
        level = 15,
        action = function(self, value)
            print(value)
        end
    }
}

n:connect { g = grid.connect() }
function init() n:init() end
```
we sent a table of two values to `x` to tell it to stretch from column 1 to column 5. likewise we can stretch like this:
```
x = 1,
y = { 1, 5 },
```
and we'll get a vertical `number` across rows 1-5 (notice from the REPL printout that value = 1 is at the bottom, value = 5 is at the top).

we can also do this:
```
x = { 1, 5 },
y = { 1, 5 },
```
now we can move our point in space around in a 5x5 square. the value being printed out is now a table specifying `x` and and `y` coordinates:
```
{ 
    y = 2,
    x = 1,
}
```
and yes, we can even send these properies to `number`:
```
x = 1,
y = 1,
```
but we won't have much of anywhere to go! these three variations are called the point, line, and plane variants of a grid affordance and they affect both output and input behaviors, as well as the format of `value`. many other properties reveal alternate behaviors when a table is sent. try this:
```
x = { 1, 5 },
y = 1,
level = { 4, 15 },
```
sending two numbers to `level` specifies that high and low values that are drawn to the grid, giving our affordance the effect of a background. useful in many circumstances!

# one to many

for perspecive, let's try out how the size variants affect `toggle`:
```
n = nest_ {
    switch = _grid.toggle {
        x = 1,
        y = 1,
        level = { 4, 15 },
        action = function(self, value)
            print(value)
        end
    }
}
```
the point variant actually get's us somewhere useful - a single toggle button, `value` switching between 0 and 1. let's try out the different stretching values. this time, we end up with  multiple independent toggles all bound to the same action function. for a line, the value printed out is a table of toggle values:
```
{ 0, 1, 1, 0, 1, }
```
and stretching out to a plane we get a table of tables:
```
{ 
    { 0, 0, 1, 0, 0, },
    { 0, 0, 0, 1, 0, },
    { 0, 0, 0, 0, 1, },
    { 0, 0, 0, 1, 0, },
    { 0, 0, 1, 0, 0, },
}
```
you'll notice that the 1's and 0's are rotated 90 degrees from what's actually lit on the grid - that lets you index the value like this: `value[x][y]` rather than this: `value[y][x]`.

sidenote: in nest, triggers are non-binary - `level` lets us extend the range of output:
```
level = { 0, 4, 8, 15 },
```
now we're cycling forward from 0 to 3, with a different brightness level shown for each state.

# decoupling

both `toggle` and `number` have inputs and outputs, unlike `fill` which is simply a display. but what if we just want the output for those? add a new propery:
```
input = false,
```
key presses now have no effect, but you can set still change the value externally: `n.lever.value = 3; n.lever:update()` (did you know you can separate two commands in the REPL with a semicolin ??? I found out recently!). this is useful for displaying stuff, like a playhead position . likewise, we can set:
```
output = false
```
all is dark on the grid, but we can still see our value being printed in the REPL. what's this good for? let's do something wierd:
```
n = nest_ {
    rate = _grid.number {
        x =  { 1, 16 },
        y = 1,
        output = false
    },
    step = _grid.number {
        x = { 1, 16 },
        y = 1,
        input = false
    }
}

clock.run(function()
    while true do
        n.step.value = n.step.value % 16 + 1
        n.step:update()
        clock.sleep(0.4 / n.rate.value)
    end
end)
```
now keypresses set not the position of a light, but the rate of movement - the [clock](https://monome.org/docs/norns/clocks/) function below incriments & wraps `step` and calculates a wait time between updates based on `rate`. using two affordances, you can decouple input & output behavior - a classic monome move.

# enabling

to disable things completely, we can use the `enable` property:
```
n = nest_ {
    lever = _grid.number {
        x =  { 1, 4 },
        y = 3,
        level = { 4, 15 },
        enabled = false,
        action = function(self, value)
            print(value)
        end
    }
}
```
seems like a lot of nothing, but of course we can change things: `n.lever.enabled = true; n.tab:update()`. enabled allows you to sort of push things out of view - affordances can still operate, but you won't be able to see them or interact with them. with this, we have a recipe for pagination.

let's jump ahead:
```
n = nest_ {
    lever = _grid.number {
        x =  { 1, 4 },
        y = 3,
        level = { 4, 15 },
        action = function(self, value)
            print(self.key, value)
        end,
        enabled = function() return n.tab.value == 1 end
    },
    switch = _grid.toggle {
        x = { 1, 4 },
        y = { 3, 6 },
        level = { 4, 15 },
        action = function(self, value)
            print(self.key, value)
        end,
        enabled = function() return n.tab.value == 2 end
    },
    tab = _grid.number {
        x =  { 1, 2 },
        y = 1,
        level = { 4, 15 }
    }
}
```
there you have it, `tab` up top switches between two affordance pages (though it makes more sense to do this once you've filled up the grid). but check it out - enabled _is a function_. every time `switch` is drawn, this function checks what the value of tab is and returns a `true` or `false` accordingly. by setting a unique equlity condition for each affordance, we get pagination. 

believe it or not, you can send a function to most properties - try subsitituting:
```
level = function(self) return self.value * 3 end,
```
now `level` changes as `value` changes !

nests have enabled properties too, so if we wanted `lever` and `switch` to show up on the same page we could group them in a subnest and enable things there:
```
n = nest_ {
    pages = nest_ {
        nest_ {
            -- page 1 affordances
            
            enabled = function(self) return n.tab.value == self.key end
        },
        nest_ {
            -- page 2 affordances
            
            enabled = function(self) return n.tab.value == self.key end
        }
    },
    tab = _grid.number {
        x =  { 1, 2 },
        y = 1,
        level = { 4, 15 }
    }
}
```
notice the shortcut of using a numeric table for the `pages` nest and checking `tab` against the table key.

# automagic

sometimes we want 16 numbers. yes we could type out sixteen affordances, no let's not do that. as always: when things get repetetive, think loops.

a for loop could most certainly be used for this task, but there's an even nestier way to do things. check this out:
```
n = nest_(16):each(function(i, v)
    return _grid.number {
        x = i,
        y = { 1, 8 },
    }
end)
```
running this, we get a unique vertical number on each grid column. [look at all those functions !](https://www.youtube.com/watch?v=F-X4SLhorvw) let's take this apart:

1. `nest_(16)` creates a nest with 16 bank slots, numbered `n[1]` to `n[16]`
2. `each` is a function that runs another function for each item in a nest. 
3. the function sent to `each` recieves two arguments, the current key (numeric or string) and the current item
4. within our function we return something, this gets placed in the current slot.
5. we're returning a `number` affordance. the `x` coordinate is set to the key, `i`, which counts up to 16

phew! if that's a lot to remember, it's easy to just copy and paste the snippet above, adjusting as needed. but having all of these seperate tools at your desposal opens up some handy shortcuts beyond simple repetition. for example, using `each`, we can consolidate the repeated function in the last pagination example:
```
pages = nest_ {
    nest_ {
        -- page 1 affordances
    },
    nest_ {
        -- page 2 affordances
    } 
} :each(function(i, v)
    v.enabled = function(self) return n.tab.value == self.key end
end),
```
a small enhancement, but certainly useful once the page count starts getting high!

# example

the study 2 script is a suprisingly fun step sequencer on the grid, in just 100 lines. 16 steps, a note selection page & octave page, gate selection on row 7 and a touchable playhead on row 8. take some time to study it, and feel free to make some modifications to fit your musical interests!

```
-- nest_ study 2
-- the grid & multiples
--
-- grid:
--   1 : page select
-- 2-6: note/octave
--   3: gate
--   4: step

include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'

engine.name = "PolyPerc"

scale = { 0, 2, 4, 7, 9 } -- scale degrees in semitones
root = 440 * 2^(5/12) -- the d above middle a

seq = nest_ {
    tab = _grid.number {
        x = { 1, 2 },
        y = 1,
        level = { 4, 15 },
    },
    pages = nest_ {
        nest_ {
            notes = nest_(16):each(function(i)
                return _grid.number {
                    x = i,
                    y = { 2, 6 },
                    value = math.random(1, 5), -- initialize every note with a random number
                    
                    -- adjust the brightness level based on step & gates
                    level = function(self)
                        if seq.gates.value[i] == 0 then return 0 -- if this step's gate is off set brightness low
                        elseif seq.step.value == i then return 15 -- if it's the current step set level high 
                        else return 4 end -- otherwise set dim
                    end,
                }
            end),
            enabled = function(self)
                return (seq.tab.value == self.key)
            end
        },
        nest_ {
            octaves = nest_(16):each(function(i)
                return _grid.number {
                    x = i,
                    y = { 2, 6 },
                    value = 3,
                    level = function(self)
                        if seq.gates.value[i] == 0 then return 0
                        elseif seq.step.value == i then return 15
                        else return 4 end
                    end
                }
            end),
            enabled = function(self)
                return (seq.tab.value == self.key)
            end
        }
    },
    gates = _grid.toggle {
        x = { 1, 16 },
        y = 7,
        level = 4,
        value = 1 -- a shortcut, toggle knows to set all the toggle values to 1
    },
    step = _grid.number {
        x = { 1, 16 },
        y = 8
    }
}

-- sequencer counter
count = function()
    while true do -- loop forever
        
        local step = seq.step.value -- the current step
        
        if seq.gates.value[step] == 1 then -- if the current gate is high
            
            -- find note frequency
            local note = scale[seq.pages[1].notes[step].value]
            local octave = seq.pages[2].octaves[step].value - 4
            local hz = root * 2^octave * 2^(note/12)
            
            engine.hz(hz) -- send a note to the engine
        end
        
        seq.step.value = step % 16 + 1 -- incriment & wrap step
        seq.step:update()
        
        clock.sync(1/4) -- wait for the next quarter note
    end
end

-- connect the nest to a grid device
seq:connect {
    g = grid.connect()
}

-- initialize the nest, start counting
function init()
    seq:init()
    clock.run(count)
end
```

# challenge

- add another toggle in the top right to reverse sequence playback
- change the transposition of the octave page to fifths rather than octaves.
- add a `number` to control the tempo on `y = 1, x = { 3, 14 }` (we're using the global clock, so map it to the [global tempo param](https://monome.org/docs/norns/clocks/#parameters).
- disable the playhead jumping input on `step` and add an output-disabled `length` control (so hitting a key detirmines the length of the sequence).
- modify pages 1 & 2 to have thier own independent `step` and `length` affordances, incrimenting & wrapping them independently in the clock. you'll be left with something a bit like awake, with transposition patterns phasing against notes !
- connect to crow, midi, etc.
- do many, many other things that can be done with sequencers. if this is your thing you don't even need to read the rest of these studies!

# continued

- part 1: [nested affordances](./study1.md)
- part 2: multiplicity
- part 3: [affordance overview](./study3.md)
- part 4: [state & meta-affordances](./study4.md)
