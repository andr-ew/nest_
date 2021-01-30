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
now `level` changes when `value` changes!

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

sometimes we want 16 numbers.
