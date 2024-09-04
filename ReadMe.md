## What

Labeled strings tree codec to Lua tables.


## Requirements

* Lua 5.3 (5.4 is fine too)


## Basic usage

* Convert [Data.lua](Data.lua) to [Data.is](Data.is):

  ```$ lua RunSave.lua```

* Convert [Data.is](Data.is) to [Data.lua](Data.lua):

  ```$ lua RunLoad.lua```


## Interesting design things

* [Format specification](Itness.txt) itself
* [Abstracted output](workshop/concepts/StreamIo/Output.lua)
* [Formatting](Serializer/) is separated from data serialization
* * Formatting via [event handler](Serializer/DelimitersWriter/Interface.lua)


## See also

  * [My other repositories](https://github.com/martin-eden/contents)

-- Martin, 2024-07/2024-09
