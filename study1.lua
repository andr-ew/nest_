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

