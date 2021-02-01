# light em up

well by now you may have noticed that nothing quite that interesting has happened - let's change that... or, well we'll try. things lighting up is a decent shot.

time to plug in a grid. we'll add one more module to the stack this time around:
```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
```
for starters not that we're actually working with harware we'll need to add an extra step to tell our nest to connect to that harware:
 ```
 our_nest:connect {
    g = grid.connect()
 }
 ```
the keys & values of that connect table are specific to each device & you can connect a single nest to any number of devices - or you can have two nests talking to two different grids.

lights time!
```
n = nest_ {
    light = _grid.fill {
        x = 1,
        y = 1,
        level = 15
    }
}

n:connect { g = grid.connect() }
function init() n:init() end
```
well, just one light - in the upper left corner - but hey at least something is happening now. we've introduced our first grid affordance, called `fill`, which lives in a handy table for all the grid affordances called `_grid`. each affordance brings along it's own set of properties in addition to the basics (often the property names are shared throughout the module, so you don't have to memorize a long list of terms & definitions for each inddividual affordance). pretty expected stuff so far - `x` and `y` set a position, `level` sets led brightness. 

you probably already know what will happen when you run `n.light.x = 5; n.light:update()`. (did you know you can separate two lua commands in re REPL with a semicolin??? I found out recently). these three properties change the appearence - or output behavior - of the affordance. other affordances will show us properties that configure input behavior as well (some change both!)

cool. what if we set `x = { 1, 5 }` ? change it out in the script & rerun - you'll see that leds 1-5 on the top row will all be lit in one swoop. and likewise:
```
x = { 1, 5 },
y = { 1, 5 },
```
will yield a 5x5 square. so we see that the dimentions of a grid affordance are changable, all through the use of two properties (try lighting up the whole grid - undoubtably useful for power outages).

# do something, please

let's swich to an affordance with some input so we can bring back that `action` function:
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
and there's your toggle switch - 1 means on, 0 means off. hit that button & get you some prints. behind the scenes, the grid's `key` callback is being set to update the nest. 

this time we're also sending a table to the level property. most grid affordances can accept a table of two - a low brighness & a high brightness. it can be helpful to give some of your affordances a "background" so they can be located amongst all the many keys.

just as before we can stretch things out:
```
x = { 1, 5 },
```
now we have not one but 5 toggles, and the value getting printed is a table of numbers:
```
{ 1, 0, 1, 1, 0, }
```
stretch things again & we'll get a table of tables:
```
x = { 1, 5 },
y = { 1, 5 },
```
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

(but wait, how are the tables printing like this??? magic!)

# it's me again, numbers

let's give `number` a whirl:
```
n = nest_ {
    lever = _grid.number {
        x =  { 1, 8 },
        y = 1,
        level = 15,
        action = function(self, value)
            print(value)
        end
    }
}
```
number can be a fader, a tab, a preset selector, a playhead - key presses assign to value a single number from 1 to the range of `x`. if we send a table to y, value will become `{ x = 1, y = 1 }`. (you can image how setting `x` and `y` to single numbers will negate the usefulnees of this affordance - there's nothing stopping you though). 

like `toggle`, `number` has input and output, but what if we just want the latter? add a new propery:
```
input = false,
```
key presses will have no effect, but you can set still change the value externally: `n.lever.value = 3; n.lever:update()`. this is useful for displaying stuff, like a sequencer position. likewise, we can set:
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
there you have it, `tab` up top switches between two affordance pages ( though it makes more sense to do this once you've filled up the grid). but check it out - enabled _is a function_. every time `switch` is drawn, this function checks the state of tab and returns `true` or `false` accordingly. by setting a unique equlity condition for each affordance, we get pagination. 

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
2. the `each` is a function that runs another function for each item in a nest. 
3. the function sent to `each` gets two arguments, the current key (numeric or string) and the current item
4. within our function we return something, this gets placed in the current slot.
5. we're returning a number affordance. the `x` coordinate is set to the key, `i`, which counts up to 16

phew! if that's a lot to remember, it's easy to just copy and paste the snippet above, adjusting as needed. but having all of these seperate tools at your desposal opens up some handy shortcuts beyond simple repetition. for example, we can consolidate the repeated function in the last pagination example:
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

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'

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

# continued

- part 1: [nested affordances](./study1.md)
- part 2: the grid & multiples
- part 3: [affordance overview](./study3.md)
- part 4: [state & meta-affordances](./study4.md)
