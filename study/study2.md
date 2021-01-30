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

you probably already know what happens when you run `n.light.x = 5; n:update()`. (did you know you can separate two lua commands in re REPL with a semicolin??? I found out recently). these three properties change the appearence - or output behavior - of the affordance. other affordances will show us properties that configure input behavior as well (some change both!)

cool. what if we set `x = { 1, 5 }` ? change it out in the script & rerun - you'll see that leds 1-5 on the top row will all be lit in one swoop. and likewise:
```
x = { 1, 5 }, 
y = { 1, 5 },
```
will yield a 5x5 square. so we see that the dimentions of a grid affordance are changable, all through the use of two properties. 

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

