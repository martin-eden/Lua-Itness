-- Convert tree of string sequences to Lua table

--[[
  Table

    { a = 'b', 1, false, [{ c = 'd'}] = 'e' }

  is serialized to such string sequence

    { 'a', {'b'}, '1', {'1'}, '2', {'false'}, {'c', {'d'}}, {'e'} }

  Here we are doing the reverse conversion.

  Note

    Error handling approach is
      * we don't throw exceptions but
      * we abort current sequence if one of it's element is bad
]]

-- Beware, we return bool(false) as result. On fail we return nil.
local ParseLeaf =
  function(Leaf)
    if not is_string(Leaf) then
      return
    end

    if (Leaf == 'true') then
      return true
    elseif (Leaf == 'false') then
      return false
    end

    local NumericValue = tonumber(Leaf)

    if is_integer(NumericValue) then
      return NumericValue
    end

    return Leaf
  end

local SeqToTable
SeqToTable =
  function(Node)
    local ParsedResult = ParseLeaf(Node)

    if not is_nil(ParsedResult) then
      return ParsedResult
    end

    --[[
      Quick reminder. 1. Table is serialized as key-value tuples.
      So it's always even number of elements. 2. Value is wrapped
      in sequence. Key is like sticky label on container.
    ]]

    -- Pre-flight checks: even number of elements
    if (#Node % 2 == 1) then
      return
    end

    -- Pre-flight checks: every even element is table with one element
    for i = 1, #Node, 2 do
      local Value = Node[i + 1]
      if not (is_table(Value) and (#Value == 1)) then
        return
      end
    end

    assert_table(Node)

    local Result = {}

    for i = 1, #Node, 2 do
      local Key = SeqToTable(Node[i])
      local Value = SeqToTable(Node[i + 1][1])

      --[[
        We don't want to deal with data in inconsistent format.

        (We may prefer just skip iteration here but I believe it
        will hide problems when I want to see them.)
      ]]
      if is_nil(Key) or is_nil(Value) then
        return
      end

      Result[Key] = Value
    end

    return Result
  end

-- Exports:
return SeqToTable

--[[
  2024-08-06
  2024-08-09
]]
