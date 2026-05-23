-- Itness to Lua

--[[
  Author: Martin Eden
  Last mod.: 2026-05-23
]]

--[[ Develop
package.path = package.path .. ';../../?.lua'
--]]
require('workshop.base')

-- [Config]
local Config =
  {
    input_file_name = 'It.is',
    output_file_name = 'Tree.lua',
  }

-- Imports:
local InputFile = request('!.concepts.StreamIo.Input.File')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local Itness = request('!.concepts.Itness.Interface')
local table_to_str = request('!.convert.table_to_str')

-- Prepare input
do
  print(string.format('Reading data from "%s".', Config.input_file_name))

  InputFile:Open(Config.input_file_name)
end

-- Prepare output
do
  print(string.format('Writing data to "%s".', Config.output_file_name))

  OutputFile:Open(Config.output_file_name)
end

local ItnessTree = Itness:Parse(InputFile)

InputFile:Close()

if not is_table(ItnessTree) then
  print('[Error] Parse error.')
  return
end

OutputFile:Write(table_to_str(ItnessTree))

OutputFile:Close()

--[[
  2024 # # # # #
  2026-05-12
  2026-05-23
]]
