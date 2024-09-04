## What

Labeled strings tree codec to Lua tables.

## Interesting design things

* [Format specification](Itness.txt) itself
* [Abstracted output](workshop/concepts/StreamIo/Output.lua)
* [Formatting](Serializer/) is separated from data serialization
* * Formatting via [event handler](Serializer/DelimitersWriter/Interface.lua)

## See also
  * [My other repositories](https://github.com/martin-eden/contents)

-- Martin, 2024-07/2024-09
