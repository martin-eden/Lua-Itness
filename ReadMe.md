## What

Labeled strings tree codec to Lua tables.

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

    Grouping via directional recursive brackets: ().
    Stackable newline/space characters for delimiter.


Special characters quoting:

  Lua:

    { 'a(', 'b)', 'c[', 'd]', 'e ', '' }

  Itness:

    a[(] b[)] c[[] d] e[ ] []

    Quoting via directional one-level quotes: [].

    One of representations (lazy quoting).


-- Martin, 2024-08/2024-10
```

Comes with Lua-Itness back-and-forth converter with pretty printing
both for Lua and Itness data.


## Requirements

* Lua 5.3 (5.4 is fine too)


## Basic usage

* Convert [`It.is`](It.is) to [`Tree.lua`](Tree.lua):

  ```$ lua ItsTree.lua```

* Convert [`Tree.lua`](Tree.lua) to [`Tree.is`](Tree.is):

  ```$ lua TreeIts.lua```


## Interesting design features

* [Syntax specification](Itness/Syntax.lua) for programmatic users
* [Abstracted input and output](workshop/concepts/StreamIo/)
* [Formatting](Itness/Serializer/) is separated from data serialization
  * Formatting via [events handler](Itness/Serializer/DelimitersWriter/OnEvent.lua)
    and decision matrix.


## See also

  * [My other repositories](https://github.com/martin-eden/contents)
