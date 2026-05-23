-- Emit closing sequence character

--[[
  Author: Martin Eden
  Last mod.: 2026-05-23
]]

local EndList =
  function(Me)
    Me.Output:Write(Me.Syntax.ListClosing)
  end

-- Export:
return EndList

--[[
  2024-10-24
]]
