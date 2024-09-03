-- Serialize string

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
]=]
local WriteLeaf =
  function(self, Data)
    assert_string(Data)

    local EncodedData = ''

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
      EncodedData = string.gsub(Data, '[%(%)%[%]% %\n]', SerializeChar)

      if (QuoteState == 'Quoted') then
        -- Close opened quote at end of value
        EncodedData = EncodedData .. ']'
        QuoteState = 'Unquoted'
      end

      if (Data == '') then
        --[[
          Special case: empty string

          By default it's serialized to an empty string and lost.
          We are serializing it to [].
        ]]
        EncodedData = '[]'
      end
    end

    self.Output:Write(EncodedData)
  end

-- Exports:
return WriteLeaf
