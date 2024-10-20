-- Formatting functions

--[[
  This class works with indentation of data. It looks for structure,
  not for data encoding.

  Interface

    Output: [StreamIo.Output]

      Output implementer.

    EventNotification
      (
        When: str (= Before, After)
        EventName: str (= StartList, EndList, Write),
        NodeType: str (= String, Container),
        NodeRole: str (= Object, Key, Value)
      )

      Generic event handler.

      I've tried approach with like 18 standalone event handlers.
      It's unmaintainable. I've tried approach with passing indices
      and list length. It's uncomprehensible.
]]

-- Internal: indentation tracker
local Indent = request('!.concepts.Indent.Interface')
Indent:Init(0, '  ')

return
  {
    -- Output implementer. Set to concrete for practical use
    Output = request('!.concepts.StreamIo.Output'),

    -- Internal: indentation tracker
    Indent = Indent,

    -- Internal: previous state
    PrevState =
      { When = nil, EventName = nil, NodeType = nil, NodeRole = nil },

    -- Adding indentation before or after writing something:
    EventNotification =
      function(self, When, EventName, NodeType, NodeRole)
        -- print(When, EventName, NodeType, NodeRole)

        --( List contents have additional indent
        if
          (When == 'After') and
          (EventName == 'StartList')
        then
          -- self:Emit('[+Indent]')
          self.Indent:Increase()
        end

        if
          (When == 'Before') and
          (EventName == 'EndList')
        then
          -- self:Emit('[-Indent]')
          self.Indent:Decrease()
        end
        --)

        --( Key is on indented newline
        if
          (When == 'Before') and
          (
            (EventName == 'StartList') or
            (EventName == 'Write')
          ) and
          (NodeRole == 'Key')
        then
          -- self:Emit('[key-line]')
          self:EmitNewlineIndent()
        end
        --)

        -- Space between key and value
        if
          (When == 'After') and
          (
            (EventName == 'EndList') or
            (EventName == 'Write')
          ) and
          (NodeRole == 'Key')
        then
          self:Emit(' ')
        end

        -- Container objects are multilined
        if
          (When == 'Before') and
          (
            (EventName == 'StartList') or
            (EventName == 'EndList')
          ) and
          (NodeType == 'Container') and
          (NodeRole == 'Object')
        then
          -- self:Emit('[multiline-object]')
          self:EmitNewlineIndent()
        end

        -- List key closing parenthesis on newline
        if
          (When == 'Before') and
          (EventName == 'EndList') and
          (NodeType == 'Container') and
          (NodeRole == 'Key')
        then
          -- self:Emit('[]')
          self:EmitNewlineIndent()
        end

        --[[
          Value's closing parenthesis is on indented newline
          when value is serialized in several lines.

          I can not track exactly this condition but if previous
          node role was "object" and now it is "value" it means
          we are writing next ")" in wrapped list.
        ]]
        if
          (When == 'Before') and
          (EventName == 'EndList') and
          (NodeType == 'Container') and
          (NodeRole == 'Value') and
          (
            (self.PrevState.EventName == 'EndList') and
            (self.PrevState.NodeRole == 'Object')
          )
        then
          -- self:Emit('[]')
          self:EmitNewlineIndent()
        end

        -- Maintenance: we are not on newline at "after" event
        if (When == 'After') then
          self.IsOnEmptyLine = false
        end

        -- Maintenance: store current arguments for the next call
        do
          -- No table constructor syntax as we don't want new table alloc.
          self.PrevState.When = When
          self.PrevState.EventName = EventName
          self.PrevState.NodeType = NodeType
          self.PrevState.NodeRole = NodeRole
        end
      end,

    --[[
      Side functionality: not-empty-liner

      I don't want empty lines in generated text. So no '\n\n'.
      But newline logic is scattered among event handlers.
    ]]
    -- Empty line flag
    IsOnEmptyLine = true,

    -- Write string (hopefully without trailing newline)
    Emit =
      function(self, s)
        self.Output:Write(s)
        self.IsOnEmptyLine = false
      end,

    -- Assure that next string will be written on new line
    EmitNewline =
      function(self)
        if self.IsOnEmptyLine then
          return
        end
        self:Emit('\n')
        self.IsOnEmptyLine = true
      end,

    -- Just emit indent string as we have access to internals
    EmitIndent =
      function(self)
        self:Emit(self.Indent:GetString())
      end,

    -- Shortcut for emitting newline and indent
    EmitNewlineIndent =
      function(self)
        self:EmitNewline()
        self:EmitIndent()
      end
  }

--[[
  2024-09-03
]]
