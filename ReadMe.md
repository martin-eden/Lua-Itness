[![DeepWiki][DeepWiki_Logo]][DeepWiki_Repo] (sometimes AI explains it better)

## What

2024, 2026

_Itness_ is a strings tree serialization format. It aims for minimalism,
not featurism. [Example][Example].

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


## Comparison with other tree formats

| Format | Comments | Free whitespaces | Named values | Typed values |
|-------:|:--------:|:----------------:|:------------:|:------------:|
| Is     |    ☐     |        ☑         |      ☐       |      ☐       |
| JSON   |    ☐     |        ☑         |      ☑       |      ☑       |
| YAML   |    ☑     |        ☐         |      ☑       |      ☑       |


## Interesting design features

* [Syntax specification][Syntax] is the only place where we use hardcoded characters
* [Abstracted input and output][StreamIo]
* Formatting is [separated][DataDelims] from data serialization
  * Formatting via [events handler][EventHandler] and decision matrix


## Shipment

[Recode][Recode] is a command-line tool that recodes data in this format.

It's used mostly for testing. Input format for it is

```
[ input_file_name [output_file_name] ]
```

Default `input_file_name` is [`it.is`][it_is].
Default `output_file_name` is [`recoded.it.is`][recoded_it_is]

Main usage is load/save data to/from Lua table.

Serializing Lua table is [another][lts] project.
And code for it weights more than this codec.
(That's why we have this codec.)


## Requirements

* Linux
* Lua 5.5 (5.4, 5.3)


## See also

* [`workshop`][workshop] -- My personal Lua framework where this codec lives
* [My other repositories][repos]

[DeepWiki_Logo]: https://deepwiki.com/badge.svg
[DeepWiki_Repo]: https://deepwiki.com/martin-eden/Lua-Itness

[Example]: Sample.md

[Recode]: Recode.lua
[it_is]: it.is
[recoded_it_is]: recoded.it.is
[lts]: https://github.com/martin-eden/lua_table_serializer

[Syntax]: workshop/concepts/codec_itness/common/Syntax.lua
[StreamIo]: workshop/concepts/StreamIo/
[DataDelims]: workshop/concepts/codec_itness/compile/
[EventHandler]: workshop/concepts/codec_itness/compile/DelimitersWriter/HandleEvent.lua

[workshop]: https://github.com/martin-eden/workshop
[repos]: https://github.com/martin-eden/contents
