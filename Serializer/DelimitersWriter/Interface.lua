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

      I've tried approach with like 18 standalone even handlers.
      It's unmaintainable. I've tried approach with passing indexes
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

    -- Adding indentation before or after writing something:
    EventNotification =
      function(self, When, EventName, NodeType, NodeRole)
        print(When, EventName, NodeType, NodeRole)

        --( Contents are indented
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
          self.IsOnEmptyLine = false
          self:EmitNewline()
          self:EmitIndent()
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

        --( Container objects are multilined
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
          self.IsOnEmptyLine = false
          self:EmitNewline()
          self:EmitIndent()
        end
        --)
      end,

    --[[
      Side functionality: not-empty-liner

      I don't want empty lines in generated text. So no '\n\n'.
      But newline logic is scattered among event handlers.
    ]]
    -- Empty line flag
    IsOnEmptyLine = true,

    -- Write string (hopefully without newlines)
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
  }

--[[
  2024-09-03
]]
