[![DeepWiki][DeepWiki_Logo]][DeepWiki_Repo] (sometimes AI explains it better)

## What

2024, 2026

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

* Lua 5.3 (5.4 and 5.5 are fine too)


## Basic usage

* Convert [`It.is`][it_is] to [`Tree.lua`][tree_lua]:

  `$ lua `[`Parse.lua`][Parse]

* Convert [`Tree.lua`][tree_lua] to [`Tree.is`][tree_is]:

  `$ lua `[`Compile.lua`][Compile]


## Interesting design features

* [Syntax specification][Syntax] is the only place where we use hardcoded characters
* [Abstracted input and output][StreamIo]
* Formatting is [separated][DataDelims] from data serialization
  * Formatting via [events handler][EventHandler] and decision matrix.


## See also

* [`workshop`][workshop] -- My personal Lua framework where this codec lives
* [My other repositories][repos]

[DeepWiki_Logo]: https://deepwiki.com/badge.svg
[DeepWiki_Repo]: https://deepwiki.com/martin-eden/Lua-Itness

[it_is]: It.is
[tree_lua]: Tree.lua
[tree_is]: Tree.is

[Parse]: Parse.lua
[Compile]: Compile.lua

[Syntax]: workshop/concepts/Itness/Syntax.lua
[StreamIo]: workshop/concepts/StreamIo/
[DataDelims]: workshop/concepts/Itness/Internals/
[EventHandler]: workshop/concepts/Itness/Internals/DelimitersWriter/HandleEvent.lua

[workshop]: https://github.com/martin-eden/workshop
[repos]: https://github.com/martin-eden/contents
