-- nest_ study 5
-- making a script

include 'lib/nest_/core'
include 'lib/nest_/norns'
include 'lib/nest_/grid'
include 'lib/nest_/txt'

--[[

grid (polysub):

1-8                      9-15              16

1: pattern recorders     1-8 : controls    1-8: presets
2-8: scale octaves

screen (halfsecond):

e1: delay
e2: rate
e3: feedback
k1: reverse

--]]

polysub = include 'we/lib/polysub'
halfsecond = include 'awake/lib/halfsecond'

engine.name = 'PolySub'

function init()
    halfsecond.init()
    polysub:params()
    
    
end