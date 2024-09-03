-- Convert table with key-values to tree of strings

--[[
  Export

    func - table to sequence
]]

--[[
  Let's think about table-tree bijection.

  Table is a list of (key, value) tuples where key or value can be
  other tables or one of 8 terminal data types. Self-references are
  allowed.

  Tree (in Itness implementation) is a list of values where each value
  can be other tree or string. Self-references are not allowed.

  More, Lua tables syntax have "list" part which allows omitting keys
  for values.

  It's all solvable. Back-references, separation for hash and array
  parts, serializing functions and even upvalues..

  But lets stop and think.

  What do we want? Equivalence between Lua tables and Itness string trees?
  Yes, it's possible but WHY?

  Squeezing Lua tables to Itness will come with conceptual costs.
  Ambiguous cases. Special-cases code and comments for them.

  From the other hand I want typical key-values tables be naturally
  serializable back and forth. And sequences too. And mix of them like
  "{ 128, 0, 255, format = 'RGB' }".
]]

--[[
  Okay, for now I'm considering Lua table with bool/int/str/@ keys
  and bool/int/str/@ values.

    { 'a', amount = 5, 'b', is_enabled = true } ->
    ( 1(a) amount(5) 2(b) is_enabled(true) )

  There is ambiguity as both string(5) and integer(5) will serialize to
  "5". Same for string(true) and bool(true).

  But it's practical. Itness(true) will always be converted to bool(true).
  Itness(5) to integer(5).

  (
    Serializing float values is another design decision. Exact float
    value can be represented in hex format. Which is quite a lot of
    characters. Neat non-exact float values representation is out of
    scope of this code.

    So float values are just ignored. Not serializing to hex cause it's
    mouthful and unreadable, not serializing to "%.2f" because there is
    no one size that fits all.
  )

  So, we are iterating keys in some stable order. Serializing key,
  then serializing value as nested sequence.

  Notes
    * This way result sequence will always have even number of elements.
    * Nesting value is just for readability. "( 1 a amount 5 )" and
      "( 1(a) amount(5) )" have same complexity but last one is
      a lot easier to parse by humans.
]]

local OrderedPass = request('!.table.ordered_pass')

-- State:
local Visited = {}

-- Stringify supported terminal types or return nil
local SerizalizeLeaf =
  function(Leaf)
    if is_boolean(Leaf) then
      return tostring(Leaf)
    end
    if is_integer(Leaf) then
      return tostring(Leaf)
    end
    if is_string(Leaf) then
      return Leaf
    end
    if is_table(Leaf) then
      return
    end
  end

--[[
  Convert full-featured Lua table to table with sequence of
  strings or other sequences.

  For key-values we do support only bool/integer/string keys and values.
  No nils, floats, funcs, userdatas and threads.
]]
local TableToSeq
TableToSeq =
  function(Node)
    local StringValue = SerizalizeLeaf(Node)

    if not is_nil(StringValue) then
      return StringValue
    end

    if is_table(Node) then
      if Visited[Node] then
        return Visited[Node]
      end

      Visited[Node] = '(* in process *)'

      local Result = {}

      for Key, Value in OrderedPass(Node) do
        local StringKey = TableToSeq(Key)

        if is_nil(StringKey) then
          goto Next
        end

        local StringValue = TableToSeq(Value)

        if is_nil(StringValue) then
          goto Next
        end

        table.insert(Result, StringKey)
        table.insert(Result, { StringValue } )

        ::Next::
      end

      -- if Result is empty table
      if is_nil(next(Result)) then
        return
      end

      Visited[Node] = Result

      return Result
    end
  end

local TableToSeqWrapper =
  function(Node)
    Visited = {}
    return TableToSeq(Node)
  end

-- Export:
return TableToSeqWrapper

--[[
  2024-08-06
  2024-08-09
]]
