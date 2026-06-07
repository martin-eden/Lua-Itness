-- Itness to Lua

--[[
  Author: Martin Eden
  Last mod.: 2026-06-07
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
local itness_parse = request('!.concepts.codec_itness.parse')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local table_to_str = request('!.convert.table_to_str')

local ItnessTree

print(string.format('Reading data from "%s".', Config.input_file_name))
do
  InputFile:Open(Config.input_file_name)
  ItnessTree = itness_parse(InputFile)
  InputFile:Close()
end

print(string.format('Writing data to "%s".', Config.output_file_name))
do
  OutputFile:Open(Config.output_file_name)
  OutputFile:Write(table_to_str(ItnessTree))
  OutputFile:Close()
end

--[[
  2024 # # # # #
  2026-05 # #
  2026-06-07
]]
