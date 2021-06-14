# video

[https://www.youtube.com/watch?v=-vYwMogt0gE](https://www.youtube.com/watch?v=-vYwMogt0gE)

# hi

hi! ok. well for starters here let's make a blank script in your `nest_` folder. it's great fun following along. nest is a library, so before digging in we have to include some stuff:

```
include 'lib/nest/core'
include 'lib/nest/norns'
```

nest is a folder of lua files, we call the lua files modules. `core` & `norns` are the modules that are required at minimum. ~ cool ~

# nesting

we introduced you to `nest_` and `_affordance` in the [intro](https://github.com/andr-ew/nest_). both are special cases of the plain old lua [table](https://monome.org/docs/norns/study-2/#tables-everywhere), with secret functions that allow them to do various cool other things. let's make a nest:
```
n = nest_ { foo = 42 }
```
easy! looks like a table to me. for the lua nerds, note this is actually a syntactially-sugary form of:
```
n = nest_:new({ foo = 42 })
```
I think you'll agree the first form is nicer. while we're at it, there's one more style to know about:
```
n = nest_(10)
m = nest_('a', 'b', 'c')
```
both these make a nest with more nests already inside of it. `n` with have sub-nests from `n[1]` to `n[10]`, `m` will have sub-nests `m.a`, `m.b`, `m.c`. that'll come in handy a little later.

so yes, we can put nests in nests (hence the name). you'll usually do it this way:
```
dave = nest_ {
    things = nest_ {
    },
    more_things = nest_ {
    }
}
```
or maybe like this:
```
dave = nest_ {
    nest_ {
    },
    nest_ {
    }
}
```
(the difference of course is in how they are addressed, `dave.more_things` vs. `dave[2]`. same old table basics here!)

# affording

affordances also live in nests. 

affordances look much like nests like tables, but typically what you fill them with has special meaning. the fillings are called properties. the two universal properties are `value` and `action`.
```
dave = nest_ {
    elanore = _affordance {
        value = 0,
        action = function(self, value)
            print(value)
        end
    }
}
```
action is a function, value can be anything (usually it's a number or many numbers). the idea here is whenever value changes, it's sent as the second argument to the `action` function. it's a very similar principle to how the [`params`](https://monome.org/docs/norns/study-3/#parameters) system operates. if you paste the snippet above in your blank script, we can test this out in the REPL.

run `dave.elanore.value = 5` followed by `dave.elanore:update()`

in the output we should get ourselves a nice wonderful:
```
5
```

simple stuff. we set the value directly, and the `update` function takes the value and sends it to `action`. the first argument to action we've called `self` and it gets assigned to the affordance calling action in the first place (`elanore`).

# who and where

affordances come with some special properties that help us know who we are and what's around us:
```
dave = nest_ {
    dale = _affordance {
        value = 5,
        action = function(self, value)
            print("my name is " .. self.key)
            print("my value is " .. value)
        end
    },
    elanore = _affordance {
        value = 6,
        action = function(self, value)
            print("my name is " .. self.key)
            print("my value is " .. value)
            print("dale's value is " .. self.parent.dale.value)
        end
    }
}
```
this time, we can just call `dave:update()` to update the whole structure and run the action functions. you'll get something like this (exact order might be scrambled):
```
my name is dale
my value is 5
my name is elanore
my value is 6
dale's value is 5
```
with `self.key` we can access the name that was given to the affordance within its parent nest (be it `elanore` or `5`). there's also `parent` which returns the nest one level up from the affordance. if you need two levels up, you can access `parent.parent` or however deep your family tree runs. within elenore, we're able to get the value of our sibling `dale` by looking at our dad `dave` and going back down from there:
```
print("dale's value is " .. self.parent.dale.value)
```

# birds eye

one more special nest trick - in the REPL, call `print(dave)`. what we get back out is nearly what we put in:
```
{ 
    elanore = _affordance { 
        value = 6,
        observable = true,
        enabled = true,
        persistent = true,
        action = function() end,
    },
    dale = _affordance { 
        value = 5,
        observable = true,
        enabled = true,
        persistent = true,
        action = function() end,
    },
    enabled = true,
    observable = true,
    persistent = true,
}
```
this can be useful for checking in on the system, the values and other properties will show their current state as changes are made. we even get a glimpse at some more properties that come pre-set with a new nest or affordance (we'll cover what their particular meanings later on). `action` and `value` also come pre-set. if we print a blank affordance we can still see them there:
```
print(_affordance {})
```
```
{ 
    action = function() end,
    persistent = true,
    observable = true,
    enabled = true,
    value = 0,
}
```
this means that we don't need to provide `value` to an affordance (or even `action`) - the affordance will always be pre-supplied with some kind of neutral state. this will be the case for any propery of a particular affordance (some affordances have lots of properties - you don't need to understand all of them to use it).

# beginning

typically, whenever our norns script loads we'll want to kick things off by updating all affordances. for this, we have a special function called `init` which does the updating in addition to some other behind the scenes tasks. natually we stick this in the init global function:
```
function init()
    dave:init()
end
```
if we re-run the snippet we'll see those printouts right away.

# light em up

well by now you may have noticed that nothing quite that interesting has happened - let's change that... or, well we'll try. things lighting up is a decent shot.

plug in the grid & start a fresh script. we'll add one more module to the stack this time around:
```
include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'
```
for starters, now that we're actually working with harware we'll need to add an extra step to tell our nest to connect to that harware:
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
well, just one light - in the upper left corner - but hey at least something is happening now. we've introduced our first grid affordance, called `fill`, which lives in a handy table for all the grid affordances called `_grid`. each affordance brings along it's own set of properties in addition to the basics. pretty expected stuff so far - `x` and `y` set a position, `level` sets led brightness. change `level` to 4 and you'll get something dimmer. these three properties change the appearence - or output behavior - of the affordance. other affordances will show us properties that configure input behavior as well (some change both!)

# it's me again, numbers

although `fill`, has a value, it doesn't have any particular meaning when it comes to input or output - let's switch it out for a `number`:
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
this time, we're sending a table to `x` because `number` occupies multiple keys - we're telling the affordance to stretch from 1 to 5 on the first row. running the script again you'll also see a light in the top left. as before, you can run:
```
n.light.value = 3
n.light:update()
```
in the REPL to update the value. when you run `update` this time, you'll see the light move to the the third key - but the easier way to update value is to interact wiht the grid - each keypress will scoot the light, run the action function, and print to the REPL. 

but printing is boring, let's make sounds ! 
```
engine.name = "PolyPerc"

scale = { 0, 2, 4, 7, 9 } -- scale degrees in semitones
root = 440 * 2^(5/12) -- the d above middle a

function play(deg)
    local octave = -2
    local note = scale[deg]
    local hz = root * 2^octave * 2^(note/12)
    
    engine.hz(hz)
end

n = nest_ {
    keyboard = _grid.number {
        x = { 1, 5 },
        y = 1,
        level = 15,
        action = function(self, value)
            play(value)
        end
    }
}

n:connect { g = grid.connect() }
function init() n:init() end
```
with the addition of an engine & some simple music theory we can use our `number` to index a chosen scale - each keypress pinging the engine with a new note. a teeny tiny keyboard is born!

# example

our first study script is a tiny strummed instrument with locational awareness. each `number` plays a single note based on its `value` and `y` positon before influencing the affordance above it, causing a chain reaction (simple [clock](https://monome.org/docs/norns/clocks/) delays are used to create the strumming effect).

```
include 'lib/nest/core'
include 'lib/nest/norns'
include 'lib/nest/grid'

engine.name = "PolyPerc"

scale = { 0, 2, 4, 7, 9 } -- scale degrees in semitones
root = 440 * 2^(5/12) -- the d above middle a

function play(deg, oct)
    local octave = oct - 3
    local note = scale[deg]
    local hz = root * 2^octave * 2^(note/12)
    
    engine.hz(hz)
end

strum = nest_ {
    _grid.number {
        x = { 1, 5 },
        y = 1,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
        end
    },
    _grid.number {
        x = { 1, 5 },
        y = 2,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            local above = self.parent[self.key - 1]
            
            clock.run(function()
                clock.sleep(0.2)
                
                above.value = (above.value == 1) and 5 or (above.value - 1) 
                above:update()
            end)
        end
    },
    _grid.number {
        x = { 1, 5 },
        y = 3,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            local above = self.parent[self.key - 1]
            
            clock.run(function()
                clock.sleep(0.15)
                
                above.value = math.random(5)
                above:update()
            end)
        end
    },
    _grid.number {
        x = { 1, 5 },
        y = 4,
        value = math.random(5),
        
        action = function(self, value)
            play(value, self.y)
            local above = self.parent[self.key - 1]
            
            clock.run(function()
                clock.sleep(0.1)
                
                above.value = above.value % 5 + 1,
                above:update()
            end)
        end
    }
}

strum:connect { g = grid.connect() }

function init() 
    strum:init()
end
```

# challenge:

- change to a different scale
- add another row, or widen the scale table and the affordance widths
- have row 1 affect row 4, creating an infinite loop

# continued

- part 1: nested affordances
- part 2: [multiplicity](./study2.md)
- part 3: [affordance overview](./study3.md)
- part 4: [state & meta-affordances](./study4.md)
