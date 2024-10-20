-- Itness format parsing

--[[
  Exports

    (func) - parse function
]]

-- Last mod.: 2024-10-20

local AssertIs = request('!.concepts.Class.AssertIs')
local Reader = request('!.concepts.StreamIo.Input')

--[[
  Parse string to table

  Input
    Input [Reader]

  Output
    Result (table)
]]
local Parse
Parse =
  function(Input)
    local Result = {}

    local Term = nil

    local FinalizeTerm =
      function()
        if (Term ~= nil) then
          table.insert(Result, Term)
        end
        Term = nil
      end

    local InQuotes = false

    while true do
      local Char, IsOk = Input:Read(1)

      if not IsOk then
        break
      end

      if (Char == '(') and not InQuotes then
        FinalizeTerm()
        table.insert(Result, Parse(Input))
      elseif (Char == ')') and not InQuotes then
        FinalizeTerm()
        return Result
      elseif (Char == '[') and not InQuotes then
        InQuotes = true
        --[[
          We want "term" stop being nil when we encountered quote.

          That's for empty string which is encoded as [].
        ]]
        Term = Term or ''
      elseif (Char == ']') and InQuotes then
        InQuotes = false
      elseif ((Char == ' ') or (Char == '\n')) and not InQuotes then
        FinalizeTerm()
      else
        Term = (Term or '') .. Char
      end
    end

    FinalizeTerm()

    return Result
  end

-- Just check that input supports reader's interface and call core
local ParseWrapper =
  function(Input)
    AssertIs(Input, Reader)

    return Parse(Input)
  end

-- Export:
return ParseWrapper

--[[
  2024-07-19
  2024-08-04
  2024-10-20
]]
