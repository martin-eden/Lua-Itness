[![DeepWiki][DeepWiki_Logo]][DeepWiki_Repo] (sometimes AI explains it better)

<table>
  <tr>
    <th colspan=3>Itness</th>
  </tr>
  <tr>
    <td>
      <table>
        <tr>
          <th>Updated</th>
          <td>2026-11-13</td>
        </tr>
        <tr>
          <th>Created</th>
          <td>2024-08</td>
        </tr>
        <tr>
          <th>Code size</th>
          <td>&lt; 50 K</td>
        </tr>
        <tr>
          <th>License</th>
          <td>LGPL3</td>
        </tr>
      </table>
    </td>
    <td align=center>
      Strings tree codec
    </td>
    <td>
      <table>
        <tr>
          <th>Input</th>
          <th>Output</th>
        </tr>
        <tr>
          <td>
            table
            <br>
            <code>.is</code>
          </td>
          <td>
            <code>.is</code>
            <br>
            table
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

_Itness_ is a strings tree serialization format. It aims for minimalism,
not featurism. [Example][example].

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

    Stackable newline/space characters for delimiter.
    Quoting via directional one-level quotes: [].
    Grouping via directional recursive brackets: ().


Special characters quoting:

  Lua:

    { '(', ')', '[', ']', ' ', '' }

  Itness:

    ( [(] [)] [[] ] [ ] [] )


-- Martin, 2024-08
```


## Comparison with other tree formats

| Format | Comments | Free whitespaces | Named values | Typed values |
|-------:|:--------:|:----------------:|:------------:|:------------:|
| Is     |    ☐     |        ☑         |      ☐       |      ☐       |
| JSON   |    ☐     |        ☑         |      ☑       |      ☑       |
| YAML   |    ☑     |        ☐         |      ☑       |      ☑       |


## Interesting design features

* [Syntax specification][syntax] is the only place where we use hardcoded characters
* [Abstracted input and output][streams]
* Formatting is [separated][data_delims] from data serialization
  * Formatting via [events handler][event_handler] and decision matrix


## Shipment

Repository contains

  * Compiled code in [`deploy/`](deploy)
  * Sample input/output in [`samples/`](samples/)
  * Complete source code in [`src/`](src)
  * Rebuild script and tools in [`builder/`](builder/)

[`recode_is`][recode_is] is a command-line tool that recodes data in this format.
Used mostly for testing. Arguments for it are `input_file_name output_file_name`.

Main codec usage is load/save data to/from Lua table.


## Requirements

* Linux
* Lua 5.5 (5.4, 5.3)


## See also

* [Lua table serializer][lts]
* [`workshop`][workshop] -- My personal Lua framework
* [My other projects][repos]

[DeepWiki_Logo]: https://deepwiki.com/badge.svg
[DeepWiki_Repo]: https://deepwiki.com/martin-eden/Lua-Itness

[example]: Sample.md

[recode_is]: src/recode_is.lua

[syntax]: src/workshop/concepts/codec_itness/syntax.lua
[streams]: src/workshop/concepts/streams/
[data_delims]: src/workshop/concepts/codec_itness/compile/
[event_handler]: src/workshop/concepts/codec_itness/compile/delimiters_writer.lua

[lts]: https://github.com/martin-eden/lua_table_serializer
[workshop]: https://github.com/martin-eden/workshop
[repos]: https://github.com/martin-eden/contents
