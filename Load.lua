-- Itness format parsing

--[[
  Exports

    (func) - parse function
]]

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

    local CloseTerm =
      function()
        if (Term ~= nil) then
          table.insert(Result, Term)
        end
        Term = nil
      end

    local QuoteState = 'Unquoted'

    while true do
      local Char, IsOk = Input:Read(1)

      if not IsOk then
        break
      end

      if (Char == '(') and (QuoteState == 'Unquoted') then
        CloseTerm()
        table.insert(Result, Parse(Input))
      elseif (Char == ')') and (QuoteState == 'Unquoted') then
        CloseTerm()
        return Result
      elseif (Char == '[') and (QuoteState == 'Unquoted') then
        QuoteState = 'Quoted'
      elseif (Char == ']') and (QuoteState == 'Quoted') then
        QuoteState = 'Unquoted'
      elseif ((Char == ' ') or (Char == '\n')) and (QuoteState == 'Unquoted') then
        CloseTerm()
      else
        Term = (Term or '') .. Char
      end
    end

    CloseTerm()

    return Result
  end

--[[
  Remove one folding level from result

  Input:
    [Reader]

  Output:
    table or nil

  Because parser happily parses "a b" to {'a', 'b'}.
  But we are expecting input within parenthesis: "(a b)".
  Which is parsed as { {'a', 'b'} }.

  In case when input is not in parenthesis, we return nil.
]]
local ParseWrapper =
  function(Input)
    AssertIs(Input, Reader)

    local Result = nil

    local ParseResult = Parse(Input)

    if (#ParseResult == 1) and is_table(ParseResult[1]) then
      Result = ParseResult[1]
    end

    return Result
  end

-- Export:
return ParseWrapper

--[[
  2024-07-19
  2024-08-04
]]
