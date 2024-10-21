-- Itness format serialization

-- Imports:
local AssertIs = request('!.concepts.Class.AssertIs')
local Output = request('!.concepts.StreamIo.Output')
local DataWriter = request('DataWriter.Interface')
local Indenter = request('DelimitersWriter.Interface')

--[[
  Serialize tree node dispatcher

  Input
    Node: string or table
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
