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

--[[
  Serialize tree node

  Input
    Node (string or table)

  Output
    none
]]
local Serialize
Serialize =
  function(NodeIndex, Node)
    if is_string(Node) then
      Indenter:WriteNode_Before(NodeIndex, Node)
      DataWriter:WriteData(Node)
      Indenter:WriteNode_After(NodeIndex, Node)
    elseif is_table(Node) then
      --[[
        Indenter implementation tracks node index.
        So before going to process sublist we should store
        current state.
      ]]
      local OurIndenter = Indenter
      Indenter = new(Indenter)

      Indenter:StartList_Before(Node)
      DataWriter:StartList()
      Indenter:StartList_After(Node)

      for Index, Value in ipairs(Node) do
        Serialize(Index, Value)
      end

      Indenter:EndList_Before(Node)
      DataWriter:EndList()
      Indenter:EndList_After(Node)

      Indenter = OurIndenter
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

    Serialize(1, Tree)

    Writer:Write('\n')
  end

-- Exports:
return SerializeWrapper

--[[
  2024-07-19
  2024-08-04
  2024-09-02
]]
