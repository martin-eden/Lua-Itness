-- Formatting functions

--[[
  This class works with indentation of data. It looks for structure,
  not for data encoding.

  Interface

    Output: [StreamIo.Output]

      Output implementer.

    StartList_Before
    StartList_After
    EndList_Before
    EndList_After
      (self, List: table)

      Event handlers before and after starting and ending sequence.

    WriteNode_Before
    WriteNode_After
      (self, NodeIndex: int, Node: table/str)

      Event handler for writing element.

    /*
      I would prefer to design "before" and "after" families as
      subtables, but then you need to call event handler like
      "DelimWriter.StartList.Before(DelimWriter, List)", versus
      "DelimWriter:StartList_Before(List)".
    */
]]

--[[
  Implementation

    We are storing state in "self".

    Currently we are tracking last event and list length.
]]

return
  {
    -- Output implementer. Set to concrete for practical use
    Output = request('!.concepts.StreamIo.Output'),

    -- Internal: last event: (StartList, EndList, WriteNode)
    LastEvent = nil,
    -- Internal: sequence length
    ListLength = nil,

    -- Opening list sequence events:
    StartList_Before =
      function(self, List)
        -- print('StartList_Before')
        if
          (self.LastEvent == 'WriteNode') or
          (self.LastEvent == 'EndList')
        then
          self.Output:Write(' ')
        end
      end,
    --
    StartList_After =
      function(self, List)
        -- print('StartList_After')
        self.LastEvent = 'StartList'
        self.ListLength = #List
      end,

    -- Closing list sequence events:
    EndList_Before =
      function(self, List)
      end,
    --
    EndList_After =
      function(self, List)
        if self:IsValue() then
          -- Value list ends line:
          self.Output:Write('\n')
        end

        self.LastEvent = 'EndList'
        self.ListLength = nil
      end,

    -- Writing node events:
    WriteNode_Before =
      function(self, NodeIndex, Node)
        if self:IsKey(NodeIndex) then
          -- Key starts from a new line:
          self.Output:Write('\n')
          return
        end
    end,
    --
    WriteNode_After =
      function(self, NodeIndex, Node)
        self.LastEvent = 'WriteNode'
      end,

    -- Internal:
    -- Node looks like a key?
    IsKey =
      function(self, NodeIndex)
        --[[
          Node looks like key in sequence of key-value tuples?

          { a = 'b' } is sequenced to {'a', {'b'}}

          So key should be in odd position and length of table
          is even and more than zero.
        ]]
        local IsKey =
          (NodeIndex % 2 == 1) and
          (self.ListLength % 2 == 0) and
          (self.ListLength > 0)

        --[[
        if IsKey then
          print('IsKey')
          print(NodeIndex)
        end
        --]]

        return IsKey
      end,

    -- List looks like a value?
    IsValue =
      function(self)
        --  That means we are in table with one element.
        local IsValue = (self.ListLength == 1)

        --[[
        if IsValue then
          print('IsValue')
          print(self.ListLength)
        end
        --]]

        return IsValue
      end,
  }

--[[
  2024-09-03
]]
