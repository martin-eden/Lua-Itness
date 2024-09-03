-- Itness format serialization

--[[
  Exports

    (Tree: table, Writer: [StreamIo.Output])

      Serialize strings tree to output.
]]

local AssertIs = request('!.concepts.Class.AssertIs')

-- Output implementer. Code works with abstract class.
local Output = request('!.concepts.StreamIo.Output')

-- State: last action = (StartList, WriteLeaf, EndList)
local LastAction = ''

--[=[
  Serialize tree leaf

  Tree leaf is a string. So we are worrying only about quoting syntax
  characters. Also we doing some pretty-printing by inserting spaces.

  Problem reminder

    Terminal value is string. Container (aka list aka sequence) is
    encoded like "(" .. ")". And items delimiter is stackable " "'s
    or "\n"'s.

    What if value is "a b("?

    One-level directed quotes [] are coming to rescue: "[a b(]".
    Or "a[ b(]" if you want to open and close quote only when you
    absolutely need to.

    What if value has "[" or "]"?

    Quoting is one-level, first "[" starts quote mode, first "]" ends
    quote mode. So value "[" serialized as "[[]" and "]" is serialized
    as "]". And value " ]" is serialized as "[ ]]".

  Implementation

    State machine.

    State is "Quoted" or "Unquoted".

    "Quoted" when we emitted opening quote "[". So in this state we are
    worrying only about encountering closing quote "]" in data.

    "Unquoted" is default, emits no additional characters and works fine
    until first syntax character.

    Syntax characters

      Framing: ()
      Quoting: []
      Delimiters: " ", "\n"

    Pretty-printing state also tracks last performed action which can
    be "StartList", "WriteLeaf" or "EndList".
]=]
local WriteLeaf =
  function(Node)
    assert_string(Node)

    if
      (LastAction == 'WriteLeaf') or
      (LastAction == 'EndList')
    then
      Output:Write(' ')
    end

    local NodeStr = ''

    -- State: quoting state = (Unquoted, Quoted)
    do
      local QuoteState = 'Unquoted'

      -- Encode character
      local SerializeChar =
        function(Char)
          if
            (QuoteState == 'Unquoted') and
            (
              (Char == '[') or
              ((Char == '(') or (Char == ')')) or
              ((Char == ' ') or (Char == '\n'))
            )
          then
            QuoteState = 'Quoted'
            return '[' .. Char
          end

          if
            (QuoteState == 'Quoted') and
            (Char == ']')
          then
            QuoteState = 'Unquoted'
            return ']' .. Char
          end

          return Char
        end

      -- Quote syntax characters in data
      NodeStr = string.gsub(Node, '[%(%)%[%]% %\n]', SerializeChar)

      if (QuoteState == 'Quoted') then
        -- Close opened quote at end of value
        NodeStr = NodeStr .. ']'
        QuoteState = 'Unquoted'
      end

      if (Node == '') then
        --[[
          Special case: empty string

          By default it's serialized to an empty string and lost.
          We are serializing it to [].
        ]]
        NodeStr = '[]'
      end
    end

    Output:Write(NodeStr)
  end

-- Write "(" and maybe space
local StartList =
  function()
    if
      (LastAction == 'WriteLeaf') or
      (LastAction == 'EndList')
    then
      Output:Write(' ')
    end
    Output:Write('(')
  end

-- Write ")"
local EndList =
  function()
    Output:Write(')')
  end

--[[
  Serialize tree node

  Input
    Node (string or table)
    Output [Writer]

  Output
    none
]]
local Serialize
Serialize =
  function(Node)
    if is_string(Node) then
      WriteLeaf(Node)
      LastAction = 'WriteLeaf'
    elseif is_table(Node) then
      StartList()
      LastAction = 'StartList'
      for Key, Value in ipairs(Node) do
        Serialize(Value)
      end
      EndList()
      LastAction = 'EndList'
    end
  end

--[[
  Serialize wrapper with pre-flight checks

  Input
    Node (table)
    Output [Writer]

  Output
    none
]]
local SerializeWrapper =
  function(Tree, Writer)
    assert_table(Tree)

    AssertIs(Writer, Output)
    Output = Writer

    Serialize(Tree)

    Output:Write('\n')
  end

-- Exports:
return SerializeWrapper

--[[
  2024-07-19
  2024-08-04
  2024-09-02
]]
