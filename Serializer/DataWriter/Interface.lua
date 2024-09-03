-- Data serialization functions

--[[
  This class knows nothing about structure and just writes to output
  syntax-specific strings and does value serialization.

  Interface

    Output: [StreamIo.Output]

      Output implementer.

    StartList(self)

      Emit sequence opening.

    EndList(self)

      Emit sequence closure.

    WriteData(self, Data: str)

      Encode string value.
]]

return
  {
    -- Generic output. Caller should set it to concrete implementer.
    Output = request('!.concepts.StreamIo.Output'),

    -- Emit opening sequence character
    StartList =
      function(self)
        self.Output:Write('(')
      end,

    -- Emit closing sequence character
    EndList =
      function(self)
        self.Output:Write(')')
      end,

    -- Serialize string
    WriteData = request('WriteData'),
  }
