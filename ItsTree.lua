-- Itness to Lua

--[[
  Author: Martin Eden
  Last mod.: 2026-05-12
]]

--[[ Develop
package.path = package.path .. ';../../?.lua'
--]]
require('workshop.base')

-- [Config]
local InputFileName = 'It.is'
local OutputFileName = 'Tree.lua'

-- Imports:
local InputFile = request('!.concepts.StreamIo.Input.File')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local Parser = request('Itness.Parser.Interface')
local SerializeTable = request('!.convert.table_to_str')

-- Prepare input
do
  InputFile:Open(InputFileName)

  print(string.format('Reading data from "%s".', InputFileName))
end

-- Prepare output
do
  OutputFile:Open(OutputFileName)
  print(string.format('Writing data to "%s".', OutputFileName))
end

Parser.Input = InputFile
local ItnessTree = Parser:Run()

InputFile:Close()

if not is_table(ItnessTree) then
  print('[Error] Parse error.')
  return
end

OutputFile:Write(SerializeTable(ItnessTree))

OutputFile:Close()

--[[
  2024 # # # # #
  2026-05-12
]]
