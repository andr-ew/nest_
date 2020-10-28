# types

[nest_](#nest_) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [print](#print)
  - [init](#init)
  - [each](#each)
  - [set](#set)
  - [get](#get)
  - [put](#put)
  - [read](#read)
  - [write](#write)
  - [connect](#connect)
  
}

[_control](#_control) {
  - [p](#p)
  - [k](#k)
  - [z](#z)
  - [enabled](#enabled)
  - [print](#print)
  
}

[_group](#_control) { }

# nest_

one of the two basic types in `nest_`. for introductory info, see [nests and controls](../study/study1.md)

# _control

one of the two basic types in `nest_`. for introductory info, see [nests and controls](../study/study1.md)

# _group

a simple container type for grouping controls by device or module. ex: `_grid.value`, `_enc.txt.number`

# p

a link to the parent of a child object

# k

the key of a child object

# z

the order of children within a `nest_` when drawn or updated by a device input. higher z values will be drawn or updated first, default = 0

### enabled

boolean value, sets whether a given object and its children are drawn + updated
