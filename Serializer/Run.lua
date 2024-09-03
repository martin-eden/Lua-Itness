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

    NodeType: str: (Element, Key, Value)


  Output

    Uses output class.
]]
local Serialize
Serialize =
  function(Node, NodeType)
    if is_string(Node) then
      if (NodeType == 'Element') then
        Indenter:Element_WriteString_Before()
      elseif (NodeType == 'Key') then
        Indenter:Key_WriteString_Before()
      else
        Indenter:Value_WriteString_Before()
      end

      DataWriter:WriteData(Node)

      if (NodeType == 'Element') then
        Indenter:Element_WriteString_After()
      elseif (NodeType == 'Key') then
        Indenter:Key_WriteString_After()
      else
        Indenter:Value_WriteString_After()
      end

    elseif is_table(Node) then
      if (NodeType == 'Element') then
        Indenter:Element_StartList_Before()
      elseif (NodeType == 'Key') then
        Indenter:Key_StartList_Before()
      else
        Indenter:Value_StartList_Before()
      end

      DataWriter:StartList()

      if (NodeType == 'Element') then
        Indenter:Element_StartList_After()
      elseif (NodeType == 'Key') then
        Indenter:Key_StartList_After()
      else
        Indenter:Value_StartList_After()
      end

      for Index, Entity in ipairs(Node) do
        local EntityType
        if (#Node == 1) then
          EntityType = 'Element'
        elseif (Index % 2 == 1) then
          EntityType = 'Key'
        else
          EntityType = 'Value'
        end

        Serialize(Entity, EntityType)
      end

      if (NodeType == 'Element') then
        Indenter:Element_EndList_Before()
      elseif (NodeType == 'Key') then
        Indenter:Key_EndList_Before()
      else
        Indenter:Value_EndList_Before()
      end

      DataWriter:EndList()

      if (NodeType == 'Element') then
        Indenter:Element_EndList_After()
      elseif (NodeType == 'Key') then
        Indenter:Key_EndList_After()
      else
        Indenter:Value_EndList_After()
      end
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

    Serialize(Tree, 'Element')
  end

-- Exports:
return SerializeWrapper

--[[
  2024-07-19
  2024-08-04
  2024-09-02
]]
