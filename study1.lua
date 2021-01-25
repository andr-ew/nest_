include 'lib/nest_/core'
include 'lib/nest_/norns'

dave = nest_ {
    tommy = _affordance {
        value = 4,
        action = function(self, value)
            print("my value is " .. value)
        end
    },
    walter = _affordance {
        value = 5,
        action = function(self, value)
            print("my value is " .. value)
        end
    },
    elanore = _affordance {
        value = 6,
        action = function(self, value)
            print("my value is " .. value)
            print("tommy's value is " .. self.p.tommy.value)
        end
    }
}

function init()
    dave:init()
end