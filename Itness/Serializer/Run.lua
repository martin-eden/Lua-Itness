-- Itness format serialization

--[[
  Exports

    (Tree: table, Writer: [StreamIo.Output])

      Serialize strings tree to output.
]]

local AssertIs = request('!.concepts.Class.AssertIs')

-- Output interface. We will check that implementer supports it
local Output = request('!.concepts.StreamIo.Output')

-- Data serializer
local DataWriter = request('DataWriter.Interface')

-- Indenter
local Indenter = request('DelimitersWriter.Interface')


-- Get element type
--[[
  Interface

    (table/string): string (= String, Container)
]]
local GetElementType =
  function(Node)
    if is_string(Node) then
      return 'String'
    elseif is_table(Node) then
      return 'Container'
    end
  end

--[[
  Determine node role.

  If node has more than one entries, we assume it is sequence of
  key-value elements. So length of table must be even and >= 2.

  (Empty tables are not produced by sequencer and ignored.)

  I can not reduce world to keys and values. Root table. Or wrapped
  lists. They are neither keys nor values (because they have their pair).
  So "Object" for case when table has only one entry.

  Interface

    (Index: int): string (= Object, Key, Value)
]]
local GetNodeRole =
  function(Index, NumElements)
    assert_integer(Index)

    if (NumElements == 1) then
      return 'Object'
    end

    if (Index % 2 == 1) then
      return 'Key'
    else
      return 'Value'
    end
  end

--[[
  Serialize tree node dispatcher

  Input

    Node: string or table

    NodeRole: str: (= Object, Key, Value)

  Output

    Uses output class.
]]
local Serialize
Serialize =
  function(Node, NodeRole)
    local NodeType = GetElementType(Node)

    local Before = 'Before'
    local After = 'After'

    if (NodeType == 'String') then
      local Event = 'Write'

      Indenter:EventNotification(Before, Event, NodeType, NodeRole)
      DataWriter:WriteLeaf(Node)
      Indenter:EventNotification(After, Event, NodeType, NodeRole)

    elseif (NodeType == 'Container') then
      local Event = 'StartList'

      Indenter:EventNotification(Before, Event, NodeType, NodeRole)
      DataWriter:StartList()
      Indenter:EventNotification(After, Event, NodeType, NodeRole)

      for Index, Entity in ipairs(Node) do
        local EntityRole = GetNodeRole(Index, #Node)
        Serialize(Entity, EntityRole)
      end

      local Event = 'EndList'

      Indenter:EventNotification(Before, Event, NodeType, NodeRole)
      DataWriter:EndList()
      Indenter:EventNotification(After, Event, NodeType, NodeRole)
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

    DataWriter.Output = Writer
    Indenter.Output = Writer

    Serialize(Tree, GetNodeRole(1, 1))

    Writer:Write('\n')
  end

-- Exports:
return SerializeWrapper

--[[
  2024-07-19
  2024-08-04
  2024-09-02
]]
