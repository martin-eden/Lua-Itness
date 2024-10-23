## What

_Itness_ is a list of items where each item is a string or list of items.

```
"Itness", tree serialization format

Proposed extension: .is


Tree:

  ASCII:

      a
     / \
    b   c
       /
      d

  Lua:

    { 'a', { 'b' }, { 'c', { 'd' } } }

  Itness:

    a ( b ) ( c ( d ) )

    Stackable newline/space characters for delimiter.
    Quoting via directional one-level quotes: [].
    Grouping via directional recursive brackets: ().


Special characters quoting:

  Lua:

    { 'a(', 'b)', 'c[', 'd]', 'e ', '' }

  Itness:

    a[(] b[)] c[[] d] e[ ] []

    One of representations (lazy quoting).


-- Martin, 2024-08/2024-10
```

Comes with Lua-Itness back-and-forth converter with pretty printing.


## Requirements

* Lua 5.3 (5.4 is fine too)


## Basic usage

* Convert [`It.is`](It.is) to [`Tree.lua`](Tree.lua):

  `$ lua `[`ItsTree.lua`](ItsTree.lua)

* Convert [`Tree.lua`](Tree.lua) to [`Tree.is`](Tree.is):

  `$ lua `[`TreeIts.lua`](TreeIts.lua)


## Interesting design features

* [Syntax specification](Itness/Syntax.lua) for programmatic users
* [Abstracted input and output](workshop/concepts/StreamIo/)
* [Formatting](Itness/Serializer/) is separated from data serialization
  * Formatting via [events handler](Itness/Serializer/DelimitersWriter/OnEvent.lua)
    and decision matrix.


## See also

  * [My other repositories](https://github.com/martin-eden/contents)
