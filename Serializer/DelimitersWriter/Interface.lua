-- Formatting functions

--[[
  This class works with indentation of data. It looks for structure,
  not for data encoding.

  Interface

    Output: [StreamIo.Output]

      Output implementer.

    Key_StartList_Before
    Key_StartList_After
    Value_StartList_Before
    Value_StartList_After

    Key_EndList_Before
    Key_EndList_After
    Value_EndList_Before
    Value_EndList_After
      (self, Node: table/str)

      Event handlers for opening/closing list.

    Key_WriteString_Before
    Key_WriteString_After
    Value_WriteString_Before
    Value_WriteString_After
      (self, Node: table/str)

      Event handlers for writing element.

    /*
      I would prefer to design "before" and "after" families as
      subtables, but then you explicitly to manually pass "self"
      and call event handler like
      "DelimWriter.StartList.Before(DelimWriter, ...)", versus
      "DelimWriter:StartList_Before(...)".
    */

    /*
      That awfully long list of handlers!

      Well, my use case is representing Lua tables which are sequenced
      as "key (value)" pairs. I want "<indent>key (<newline>" for the
      key part. Both "key" and "value" can be strings or lists. So
      what is "key" is determined by element position in parent list.

      I can cut those 12 handlers to 6 by passing position, but
      I prefer this way. Extensive dumbness is more manageable than
      compacted trickery.
    */
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

    -- Writing node events:
    Element_WriteString_Before =
      function(self, Node)
        -- self:Emit('[Element_WriteString_Before]')
      end,

    Element_WriteString_After =
      function(self, Node)
        -- self:Emit('[Element_WriteString_After]')
        -- self:EmitIndent()
      end,

    Key_WriteString_Before =
      function(self, Node)
        -- self:Emit('[Key_WriteString_Before]')
        self:EmitNewline()
        self:EmitIndent()
      end,

    Key_WriteString_After =
      function(self, Node)
        -- self:Emit('[Key_WriteString_After]')
        self:Emit(' ')
      end,

    Value_WriteString_Before =
      function(self, Node)
        -- self:Emit('[]')
        self:EmitIndent()
      end,

    Value_WriteString_After =
      function(self)
        -- self:Emit('[Value_WriteString_After]')
      end,

    -- Opening list sequence events:
    Element_StartList_Before =
      function(self, Node)
        -- self:Emit('[Element_StartList_Before]')
        self:EmitNewline()
        self:EmitIndent()
      end,

    Key_StartList_Before =
      function(self, Node)
        -- self:Emit('[Key_StartList_Before]')
        self:EmitNewline()
        self:EmitIndent()
      end,

    Value_StartList_Before =
      function(self, Node)
        -- self:Emit('[Value_StartList_Before]')
      end,

    Element_StartList_After =
      function(self, Node)
        -- self:Emit('[Element_StartList_After]')
        -- self:EmitNewline()
        self.Indent:Increase()
      end,

    Key_StartList_After =
      function(self, Node)
        -- self:Emit('[Key_StartList_After]')
        -- self:EmitNewline()
        self.Indent:Increase()
      end,

    Value_StartList_After =
      function(self, Node)
        -- self:Emit('[Value_StartList_After]')
        -- self:EmitNewline()
        self.Indent:Increase()
      end,

    -- Closing list sequence events:
    Element_EndList_Before =
      function(self, Node)
        -- self:Emit('[Element_EndList_Before]')

        self.Indent:Decrease()

        self:EmitNewline()
        self:EmitIndent()
      end,

    Element_EndList_After =
      function(self, Node)
        -- self:Emit('[Element_EndList_After]')

        self:EmitNewline()
      end,

    Key_EndList_Before =
      function(self, Node)
        -- self:Emit('[Key_EndList_Before]')

        self.Indent:Decrease()
        self:EmitIndent()
      end,

    Value_EndList_Before =
      function(self, Node)
        -- self:Emit('[Value_EndList_Before]')

        self.Indent:Decrease()

        self:EmitNewline()

        -- self:EmitIndent()
      end,

    Value_EndList_After =
      function(self, Node)
        -- self:Emit('[Value_EndList_After]')
        self:EmitNewline()
      end,

    Key_EndList_After =
      function(self, Node)
        -- self:Emit('[Key_EndList_After]')
        self:Emit(' ')
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
