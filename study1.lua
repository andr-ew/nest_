-- nest_ study 1
-- nested affordances

include 'lib/nest_/core'
include 'lib/nest_/norns'

-- a nest structure named dave
dave = nest_ {
    tommy = _affordance {
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
                print("tommy's value is " .. self.parent.parent.tommy.value)
            end
        }
    }
}

function init()
    dave:init() -- initialize dave on script load, which updates all of dave's affordances
end

-- >> dave.tommy.value 
-- 5
-- >> dave.elanore.value
-- 6
-- >> dave.tommy.parent.elanore.value
-- 6
-- >> dave.tommy.key
-- tommy


-- >> dave.tommy.value = 10
-- >> dave.tommy:update()
-- my name is tommy
-- my value is 10

-- >> dave.things[2].value = 20
-- >> dave.things[2]:update()
-- I'm thing number 2
-- my value is 20
-- tommy's value is 10


-- >> print(dave.tommy)
-- >> print(dave)

