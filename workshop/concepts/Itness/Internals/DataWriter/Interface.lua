-- Data serialization functions

--[[
  Author: Martin Eden
  Last mod.: 2026-05-23
]]

--[[
  This class knows nothing about structure and just writes to output
  syntax-specific strings and does value serialization.

  Interface

    .Output: [StreamIo.Output]

      Output implementer

    :StartList()

      Emit sequence opening

    :EndList()

      Emit sequence closure

    :WriteData(Data: str)

      Encode string value
]]

-- Imports:
local fold_tree = request('!.table.fold')
local map_values = request('!.table.map_values')
local list_to_string = request('!.concepts.list.to_string')
local lua_regexp_quote = request('!.lua.regexp.quote')

local Interface =
  {
    -- [Config] Output stream
    Output = { },

    -- [Config] Syntax chars structure
    Syntax = { },

    -- [Main] Initialize state
    Init =
      function(Me)
        local SyntaxCharsList = fold_tree(Me.Syntax)

        Me.IsSyntaxChar_Map = map_values(SyntaxCharsList)

        Me.syntax_chars_regexp =
          '[' ..
          lua_regexp_quote(list_to_string(SyntaxCharsList)) ..
          ']'
      end,

    -- [Main] Emit opening sequence character
    StartList = request('StartList'),

    -- [Main] Emit closing sequence character
    EndList = request('EndList'),

    -- [Main] Serialize string
    WriteLeaf = request('WriteLeaf'),

    -- [Internals]:
    SyntaxChars = SyntaxChars,
    IsSyntaxChar_Map = { },
    syntax_chars_regexp = '',
  }

-- Export:
return Interface

--[[
  2024-09-03
  2024-10-20
]]
