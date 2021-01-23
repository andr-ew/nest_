# TODO

```

RENAME

lvl -> level. add a lvl as a nickname
add en as a nickname for enabled

zsort -> children

FIX

broken _txt.*.list (update issue probably)

ADD

init as callback except for connected nest_
nest_.redraw
nest_ refresh()/update() alt modes when redraw

nest_ {
    redraw = function(self, i) -- unpack(v)
        screen.drawthing(i)
    end,
    init = function(self)
        clock.run(function()
            while true do
                for i = 1, 3 do
                    self:refresh(i) -- v = { ... }
                    clock.sleep(0.2)
                end
            end
        end)
    end
}

nest:disconnect() : for disconnecting and reconnecting nests to devices

_key.binary.lvl -- accept clock funtion entry in table as animation

_enc.delta
_enc.affordance.sens (impliment in input.filter, v easy) also: fine tune range delta stuff for option as in _arc.option

*.option: remove the option string action argument, encourage indexing options instead

```

# readme notes

```
build personalized interfaces as a waypoint into existing musical processes (a sampler, a synth voice, a sequence)

you're welcome to think about nest as a full-blown library, a configuration language, or a maiden scriptable application in the vein of grid ops

while you can certainly build gridless/arcless applications in nest (i'll be doing this), most designs are simple enough not to really warrant a complex library. nest is an **input focused** syntax, and shines most when syncronizing many forms of interaction data

```
