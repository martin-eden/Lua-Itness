-- Parser test rig

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local SerializeTable =
  request(
    -- '!.table.as_string'
    '!.concepts.lua_table_code.save'
  )

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

if not is_table(Sequence) then
  print('Parse error.')
  return
end

-- print(SerializeTable(Sequence))

local Table = Sequencer.SeqToTable(Sequence)

Writer:Write(SerializeTable(Table))

--[[
  2024-08-04
  2024-08-09
]]
