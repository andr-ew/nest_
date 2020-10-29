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

well, just one light, it's something though ! you should see it pop up on the top left corner of the grid. we've covertly introduced the `_grid` group, which is holding our first library control, `fill`. `fill` comes pre-populated with the not-so-complicated code to render an led to the grid device that we've hooked up to its nest via `connect`. it's an output-only device, as nothing is happening when we press the lit key on the grid. it's just creating output based on properties. want more lights ? dim ones ? no problem !

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

here we've shown that `x` can accept a value range to grow the control across multiple keys. if we set `y = { 1, 8 }`, the control will fill the whole grid.

# doooo somethingggggggg

time for a doing things control

```
dave = nest_ {
  ramona = _grid.value {
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

hit a key on the top row aaand - the light ! it moves ! ... ! you should also see the value being printed to the REPL in the range 0-15 as per our action function. try switching out `ramona = _grid.toggle`. now not just one light, but up to 16, toggled on and off by fingers. our value is being printed as something like  `table: 0x7fd7fd508010` as indeed it is now a table. add `tab = require 'tabutil'` up top and set `action = function(self, value) tab.print(value) end` so we can take a look. yep, that's a table of 16 1's and 0's corresponding to the state of the buttons. if we made it a 2D control with `y = { 1, 8 }` we'd get a a table of tables, a press setting `value[x][y] = 1`.

# lotsa


