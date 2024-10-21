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
  Serialize tree node dispatcher

  Input

    Node: string or table

  Output

    Uses output class.
]]
local Serialize
Serialize =
  function(Node)
    if is_string(Node) then
      Indenter:OnEvent('WriteString')
      DataWriter:WriteLeaf(Node)

    elseif is_table(Node) then
      Indenter:OnEvent('StartList')
      DataWriter:StartList()

      for Index, Entity in ipairs(Node) do
        Serialize(Entity)
      end

      Indenter:OnEvent('EndList')
      DataWriter:EndList()
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

    for Key, Value in ipairs(Tree) do
      Serialize(Value)
    end

    Indenter:OnEvent('Nothing')
  end

-- Exports:
return SerializeWrapper

--[[
  2024-07-19
  2024-08-04
  2024-09-02
]]
