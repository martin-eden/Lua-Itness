-- Data serialization functions

--[[
  This class knows nothing about structure and just writes to output
  syntax-specific strings and does value serialization.

  Interface

    .Output: [StreamIo.Output]

      Output implementer.

    :StartList()

      Emit sequence opening.

    :EndList()

      Emit sequence closure.

    :WriteData(Data: str)

      Encode string value.
]]

-- Last mod.: 2024-10-20

local ToList = request('!.table.to_list')
local MapValues = request('!.table.map_values')
local ListToString = request('!.concepts.List.ToString')
local QuoteRegexp = request('!.lua.regexp.quote')

local Exports =
  {
    -- Generic output. Caller should set it to concrete implementer.
    Output = request('!.concepts.StreamIo.Output'),

    -- Emit opening sequence character
    StartList = request('StartList'),

    -- Emit closing sequence character
    EndList = request('EndList'),

    -- Serialize string
    WriteLeaf = request('WriteLeaf'),

    -- [Internal] Syntax characters categorization
    SyntaxChars =
      {
        QuoteOpening = '[',
        QuoteClosing = ']',
        ListOpening = '(',
        ListClosing = ')',
        Delimiters = { ' ', '\n' },
      },

    -- [Internal] Map of syntax characters. Defined later here
    IsSyntaxChar = {},
    -- [Internal] Syntax chars regexp. Defined later here
    SyntaxCharsRegexp = '',
  }

local SyntaxCharsList = ToList(Exports.SyntaxChars)

-- "IsSyntaxChar[' '] = true"
Exports.IsSyntaxChar = MapValues(SyntaxCharsList)

-- Regexp describing any of our syntax characters
-- Lua blows on "[]", so contents should not be empty.
Exports.SyntaxCharsRegexp =
  '[' ..
  QuoteRegexp(ListToString(SyntaxCharsList)) ..
  ']'

-- Exports:
return Exports

--[[
  2024-09-03
  2024-10-20
]]
