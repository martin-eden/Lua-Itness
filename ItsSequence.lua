-- Itness to Lua

-- Last mod.: 2024-10-20

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local SerializeTable = request('!.concepts.lua_table_code.save')

local Reader = request('!.concepts.StreamIo.Input.File')
local Writer = request('!.concepts.StreamIo.Output.File')

local Parse = request('Itness.Parse')

local InputFileName = 'It.is'
local OutputFileName = 'It.is.Sequence.lua'

-- Prepare input
do
  Reader:OpenFile(InputFileName)

  print(string.format('Reading data from "%s".', InputFileName))
end

-- Prepare output
do
  Writer:OpenFile(OutputFileName)
  print(string.format('Writing data to "%s".', OutputFileName))
end

local Sequence = Parse(Reader)

Reader:CloseFile()

if not is_table(Sequence) then
  print('[Error] Parse error.')
  return
end

Writer:Write(SerializeTable(Sequence))

Writer:CloseFile()

--[[
  2024-08-04
  2024-08-09
  2024-09-04
  2024-10-20
]]
