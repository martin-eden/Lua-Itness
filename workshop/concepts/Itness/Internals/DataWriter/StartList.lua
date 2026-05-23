-- Emit opening sequence character

--[[
  Author: Martin Eden
  Last mod.: 2026-05-23
]]

local StartList =
  function(Me)
    Me.Output:Write(Me.Syntax.ListOpening)
  end

-- Export:
return StartList

--[[
  2026-10-24
]]
