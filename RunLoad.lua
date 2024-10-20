-- Itness to Lua

-- Last mod.: 2024-10-20

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local SerializeTable = request('!.concepts.lua_table_code.save')

local Reader = request('!.concepts.StreamIo.Input.File')
local Writer = request('!.concepts.StreamIo.Output.File')

local Parse = request('Load')
local Sequencer = request('Sequencer.Interface')

-- Prepare input
do
  local FileName = 'Data.is'
  Reader:OpenFile(FileName)

  print(string.format('Reading data from "%s".', FileName))
end

-- Prepare output
do
  local FileName = 'Data.lua'
  Writer:OpenFile(FileName)
  print(string.format('Writing data to "%s".', FileName))
end

local Sequence = Parse(Reader)

Reader:CloseFile()

if not is_table(Sequence) then
  print('[Error] Parse error.')
  return
end

-- print(SerializeTable(Sequence))

local Table = Sequencer.SeqToTable(Sequence)

if not is_table(Table) then
  print(
    '[Error] This strings tree cannot be converted to Lua table.\n' ..
    "  (Key's value must be a list with one element.)"
  )
  return
end

Writer:Write(SerializeTable(Table))

Writer:CloseFile()

--[[
  2024-08-04
  2024-08-09
  2024-09-04
]]
