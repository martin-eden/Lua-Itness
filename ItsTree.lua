-- Itness to Lua

-- Last mod.: 2024-10-21

package.path = package.path .. ';../../?.lua'
require('workshop.base')

-- [Config]
local InputFileName = 'It.is'
local OutputFileName = 'Tree.lua'

-- Imports:
local SerializeTable = request('!.concepts.lua_table_code.save')
local Reader = request('!.concepts.StreamIo.Input.File')
local Writer = request('!.concepts.StreamIo.Output.File')
local Parser = request('Itness.Parser.Interface')

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

Parser.Input = Reader
local Sequence = Parser:Run()

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
  2024-10-21
]]
