function r()
    norns.script.load(norns.state.script)
end
--norns.script.load('/home/we/dust/code/nest_/test.lua')

include 'lib/nest_/core'
include 'lib/nest_/norns'

tab = require 'tabutil'

n = nest_ {
    a1 = nest_ {
        a2 = nest_ {
        },
        b2 = nest_ {
            a3 = nest_ {
                value = 1
            }
        }
    },
    b1 = nest_ {
        a2 = nest_ {
            a3 = nest_ {
            },
            b3 = nest_ {
                a4 = nest_ {
                    value = 1
                }
            }
        }
    }
}
