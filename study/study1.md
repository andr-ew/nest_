# hi

hi! ok. well for starters here let's make a blank script in your `nest_` folder. it's great fun following along. nest is a library, so before digging in we have to include some stuff:

```
include 'lib/nest_/core'
include 'lib/nest_/norns'
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

so yes, we can put a nests in nests (hence the name). you'll usually do it this way:
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

affordances live in nests. 

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

# example

the study 1 script is just a simple nest structure demonstrating the various techniques outlined. get comfortable changing values and calling `update` in the repl on various affordances and checking out the `parent` and `key` properties!

```
-- nest_ study 1
-- nested affordances

include 'lib/nest_/core'
include 'lib/nest_/norns'

-- a nest structure named dave
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
        end
    },
    things = nest_ {
        _affordance {
            value = 7,
            action = function(self, value)
                print("I'm thing number " .. self.key)
                print("my value is " .. value)
            end
        },
        _affordance {
            value = 8,
            action = function(self, value)
                print("I'm thing number " .. self.key)
                print("my value is " .. value)
                print("dale's value is " .. self.parent.parent.dale.value)
            end
        }
    }
}

function init()
    dave:init() -- initialize dave on script load, which updates all of dave's affordances
end
```
