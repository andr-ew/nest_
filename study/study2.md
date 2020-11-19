# lights go brrrr

alright, i know object oriented data structures implimenting concatenative prototypical inheritence is cool and all but I know why you're really here - you want to make things light up. assuming you've got a blank script with some [modules](https://github.com/andr-ew/nest_/releases/) loaded up in `lib/nest_` we can start by including them:

```
include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
```

`core` and `norns` are required for full functioning, and we're teeing off with `grid`, which is perhaps the module which benefits most from nest_'s design philosophies. for starters, we'll boot up a nest

```
n = nest_ {

} :connect {
  g = grid.connect()
}
```

now that we're using real devices, we'll want to make use of the `connect` method, which takes in norns interface objects attatched to specific keys. lights time !

```
dave = nest_ {
  ramona = _grid.fill {
    x = 1,
    y = 1,
    lvl = 15
  }
} :connect {
  g = grid.connect()
}
```

well, just one light, it's something though ! you should see it pop up on the top left corner of the grid. we've covertly introduced the `_grid` group, which is holding our first library affordance, `fill`. `fill` comes pre-populated with the not-so-complicated code to render an led to the grid device that we've hooked up to its nest via `connect`. it's an output-only device, as nothing is happening when we press the lit key on the grid. it's just creating output based on properties. want more lights ? dim ones ? no problem !

```
dave = nest_ {
  ramona = _grid.fill {
    x = { 1, 16 },
    y = 1,
    lvl = 4
  }
} :connect {
  g = grid.connect()
}
```

here we've shown that `x` can accept a value range to grow the affordance across multiple keys. if we set `y = { 1, 8 }`, the affordance will fill the whole grid. every grid affordance comes with 0D (`x = 1, y = 1`), 1D (`x = { 1, 4 }, y = 1`), and 2D (`x = { 1, 4 }, y = { 1, 4 }`) varitities.

# doooo somethingggggggg

time for a doing things affordance

```
dave = nest_ {
  ramona = _grid.number {
    x = { 1, 16 },
    y = 1,
    action = function(self, value) 
      print(`ramona's value is`, value)
    end
  }
} :connect {
  g = grid.connect()
}
```

hit a key on the top row aaand - the light ! it moves ! ... ! you should also see the value being printed to the REPL in the range 0-15 as per our action function.

try switching out `ramona = _grid.toggle`. now not just one light, but up to 16, toggled on and off by fingers. our value is being printed as something like  `table: 0x7fd7fd508010` as indeed it is now a table. add `tab = require 'tabutil'` up top and set 
```
action = function(self, value) 
  print('ramona's value is')
  tab.print(value) 
end
```
so we can take a look. yep, that's a table of 16 1's and 0's corresponding to the state of the buttons. if we made it a 2D affordance with `y = { 1, 8 }` we'd get a a table of tables, a grid press setting `value[x][y] = 1`.

# enablers

in the example code try passing ramona the propery `enabled = false`. she's gone ! boring. but let's make it less boring:

```
dave = nest_ {
  tab = _grid.number {
    x = { 1, 2 },
    y = 1
  },
  ramona1 = _grid.toggle {
    x = 2,
    y = 4,
    lvl = { 4, 15 },
    enabled = function(self) return dave.tab.value == 0 end
  },
  ramona2 = _grid.toggle {
    x = 4,
    y = 4,
    lvl = { 4, 15 },
    enabled = function(self) return dave.tab.value == 1 end
  }
} :connect {
  g = grid.connect()
}
```

oh ? we can show and hide the two ramonas with the tab `number`. indeed `enabled` can be a "pointer method" if it wants, fetching and returning data of the appropriate type (the same goes for most properties). in this case, we're asking about `dave.tab`'s value to decide whether to enable.

with the power of the nest we can quickly set up some serious multi-paginated scenarios:

```
dave = nest_ {
  tab = _grid.number {
    x = { 1, 16 },
    y = 1
  },
  pages = nest_(4):each(function(page)
    return nest_ {
      ramona1 = _grid.number {
        x = 1,
        y = { 2, 8 },
        action = function(self, value)
          print("value of page " .. page: " .. value)
        end
      },
      ramona2 = _grid.number {
        x = 3,
        y = { 2, 8 },
        action = function(self, value)
          print("value of page " .. page: " .. value)
        end
      },
      enabled = function(self) return dave.tab.value == page end
    }
  end)
}
```

this is 4 pages as nests, each with two independent values. we're using the `each()` method to fill out four identical nests auto-magically, and just like before, we're setting up a tab `number` and using an `enabled` function (in the `nest_` this time) to ask about the tab. want 16 pages of 16 values, totalling 256 independent affordances?

```
dave = nest_ {
  tab = _grid.number {
    x = { 1, 16 },
    y = 1
  },
  pages = nest_(16):each(function(page)
    return nest_ (16):each(function(i)
      return _grid.number {
        x = i,
        y = { 2, 8 },
        action = function(self, value)
          print("value of page " .. page .. " affordance " .. i ": " .. value)
        end,
        enabled = function(self) return dave.tab.value == page end
      }
    end)
  end)
}
```

BAM ! 

# the gang's all here

right now, there are 7 affordance types included in the grid module all with thier own input/output behaviors and interpretations of a common set of **properties** and **action arguments** (which are additional informative arguments sent to the defined action function). for more information on all of this, see the [grid module documentation](../doc/grid.md) and the [grid module demo script](../examples/grid.lua)
