include 'lib/nest_/core'
include 'lib/nest_/norns'

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
            print("tommy's value is " .. self.p.tommy.value)
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
            end
        }
    }
}

function init()
    dave:init()
end