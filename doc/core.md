# Hello, nest_

oh hello, I didn't hear to come in. well, let's get started then. `core` is where things begin. nothing here is really useful on it's own - just like that grid you have there on the desk with nothing plugged in into it! no, these are the _building blocks_ of an interface. we leave the _doing things_ to be filled in by later modules. come, have a seat, grab yourself one of those yuzu teas I left by the door.

there are two basic building blocks to every interface, `nest_`s and `_control`s. `_control`s are all the interactive components (or [affordances](https://jnd.org/affordances_and_design/)) that make up an [interface](https://en.wikipedia.org/wiki/User_interface). they are the main focus of the various `modules`. a `nest_` can be thought of as the interface itself, though in practice it's really just a container, not all that much different than a blank object (`{ }`). they are usuful for grouping `_controls` - perhaps they are grouped by page on a paginated interface or serve similar roles. `nest)`s can contain `control_`s, other `nest_`s, and even `_input`s and `_output`s (which we'll cover later)

# what's new

we may initialize either type by calling it as a function using `()`, like this:

```
mynest = nest_()
mycontrol = _control()
```

this is actually a cheeky form of `object:new()`, for those familiar with [OOP](https://en.wikipedia.org/wiki/Object-oriented_programming). a lonely pair of sigur ros sausages doesn't do much on it's own though, generally we'll want to spice things up with some arguments. call `n = nest_(4)` to create a nest containing four `nest_` **children**, labeled 1-4 (`n[1], n[2], n[3], n[4]`). call `dave = nest_('tommy', 'walter', 'elanore')` once you've decided that you're not a maniac, and want to give your children actual human names (`dave.tommy`, `dave.walter`, `dave.elanore`). but what are these children ? well, most of the time we'll want a say in that, so we can call `nest_` with an object argument using curly braces:

```
dave = nest_ {
  tommy = _control(),
  walter = _control(),
  elanore = _control()
}
```

the same goes for `_control`, we'll want to get a little more specific:

```
dave = nest_ {
  tommy = _control {
    age = 4
  },
  walter = _control {
    age = 7
  },
  elanore = _control {
    age = 8
  }
}
```

now things are getting interesting - here `age` is not just a **child** of a `_control`, but a **property**. typically, these properties go by specific names and configure the look or behavior of controls in meaningful ways. these might be the x or y coordinates of a control's location, a particular font of text, an encoder or key to map the control's `_input` to, etc. 

# do something

`action` is a particularly important property which is shared by all controls. it takes the form of a function and may thus be dubbed a **method**.

```
dave = nest_ {
  tommy = _control {
    age = 4,
    action = function(self, value)
      print(self.age)
    end
  },
  walter = _control {
    age = 7,
    action = funtion(self, value)
      print(self.age)
    end
  },
  elanore = _control {
    age = 8,
    action = funtion(self, value)
      print(self.age)
    end
  }
}
```
now what are _those_ arguments ? 
