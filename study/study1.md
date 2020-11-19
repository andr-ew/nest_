# Hello, nest_

oh hello, I didn't hear to come in. well, let's get started then. `core` is where things begin. nothing here is really useful on it's own - just like that grid you have there on the desk with nothing plugged in into it! no, these are the _building blocks_ of an interface. we leave the _doing things_ to be filled in by later modules. come, have a seat, grab yourself one of those yuzu teas I left by the door.

there are two basic building blocks to every interface, `nest_`s and `_affordance`s. [affordances](https://jnd.org/affordances_and_design/) are all the interactive that make up an [interface](https://en.wikipedia.org/wiki/User_interface). they are the main focus of the various `modules`. a `nest_` can be thought of as the interface itself, though in practice it's really just a container, not all that much different than a blank object (`{ }`). they are usuful for grouping affordances - perhaps they are grouped by page on a paginated interface or serve similar roles. `nest_`s can contain `affordance_`s, other `nest_`s, or anything at all.

# what's new

we may initialize either type by calling it as a function using `()`, like this:

```
mynest = nest_()
myaffordance = _affordance()
```

this is actually a cheeky form of `object:new()`, for those familiar with [OOP](https://en.wikipedia.org/wiki/Object-oriented_programming). a lonely pair of sigur ros sausages doesn't do much on it's own though, generally we'll want to spice things up with some arguments. call `n = nest_(4)` to create a nest containing four blank **children**, labeled 1-4 (`n[1], n[2], n[3], n[4]`). call `dave = nest_('tommy', 'walter', 'elanore')` once you've decided that you're not a maniac, and want to give your children actual human names (`dave.tommy`, `dave.walter`, `dave.elanore`). but what are these children ? well, most of the time we'll want a say in that, so we can call `nest_` with an object argument using curly braces:

```
dave = nest_ {
  tommy = _affordance(),
  walter = _affordance(),
  elanore = _affordance()
}
```

the same goes for `_affordance`, we'll want to get a little more specific:

```
dave = nest_ {
  tommy = _affordance {
    age = 4
  },
  walter = _affordance {
    age = 5
  },
  elanore = _affordance {
    age = 6
  }
}
```

now things are getting interesting - here `age` is not just a **child** of a `_affordance`, but a **property**. typically, these properties go by specific names and configure the look or behavior of affordances in meaningful ways. these might be the x or y coordinates of an affordance's location, a particular font of text, an encoder or key to map the affordance's `_input` to, etc. 

# do something

`action` is a particularly important property which is shared by all affordances. it takes the form of a function and may thus be dubbed a **method**.

```
dave = nest_ {
  tommy = _affordance {
    age = 4,
    action = function(self, value)
      print(self.age)
    end
  },
  walter = _affordance {
    age = 5,
    action = funtion(self, value)
      print(self.age)
    end
  },
  elanore = _affordance {
    age = 6,
    action = funtion(self, value)
      print(self.age)
    end
  }
}
```
now what are _those_ arguments ? as with all methods, the first argument is `self`. that way, no matter what, we'll never lose track of who we are. in this case, self contains `age` and `action` (and usually more under the hood), and we're acessing `self.age` to print our age to the maiden REPL. in addition, every `_affordance` contains a property called `value`, which is passed to the `action` method for convenience. whenever `value` is changed, `action` is called, it's a cause an effect sort of scenario. we can rewrite the above as:

```
dave = nest_ {
  tommy = _affordance {
    value = 4,
    action = function(self, value)
      print("I am " .. tostring(value) .. " years old!")
    end
  },
  walter = _affordance {
    value = 5,
    action = function(self, value)
      print("I am " .. tostring(value) .. " years old!")
    end
  },
  elanore = _affordance {
    value = 6,
    action = function(self, value)
      print("I am " .. tostring(value) .. " years old!")
    end
  }
}
```

in this case, perhaps the user updates `value` whenever a year goes by, and so child announces their age. 

# automagic

pretty cool, but it's kind of a hastle to rewrite that same action function three times, especially if we need to head back and make changes later. to remedy this, we need to construct a child-making factory. a lua `for` loop would suffice, but for convenience there's also the `nest_:each()` method, which frequently comes in handly. check this out:


```
dave = nest_(3):each(function(i)
  return _affordance {
    value = i + 3,
    action = function(self, value) 
      print("I am " .. tostring(value) .. " years old!")
    end
  }
end)
```

here we initialize dave with three blank children (numbered 1-3), call the `each` function and send it a _callback function_ which `return`s a `_affordance` to each blank child slot (the number of which is stored in the `i` variable). asending values and the action function can be generated for all three in one efficient swoop.
