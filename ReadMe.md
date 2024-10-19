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

    ( a ( b ) ( c ( d ) ) )

    Grouping via directional recursive brackets: ().
    Stackable space characters for delimiter.


Special characters quoting:

  Lua:

    { 'a(', 'b)', 'c[', 'd]', 'e ', '' }

  Itness:

    ( a[(] b[)] c[[] d] e[ ] [] )

    Quoting via directional one-level quotes: [].

    One of representations (lazy quoting).


-- Martin, 2024-08/2024-09
```

Comes with Lua-Itness back-and-forth converter with pretty printing
both for Lua and Itness data.


## Requirements

* Lua 5.3 (5.4 is fine too)


## Basic usage

* Convert [Data.lua](Data.lua) to [Data.is](Data.is):

  ```$ lua RunSave.lua```

* Convert [Data.is](Data.is) to [Data.lua](Data.lua):

  ```$ lua RunLoad.lua```


## Interesting design things

* [Abstracted output](workshop/concepts/StreamIo/Output.lua)
* [Formatting](Serializer/) is separated from data serialization
* * Formatting via [event handler](Serializer/DelimitersWriter/Interface.lua)


## See also

  * [My other repositories](https://github.com/martin-eden/contents)


