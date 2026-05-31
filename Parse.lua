-- Itness to Lua

--[[
  Author: Martin Eden
  Last mod.: 2026-05-26
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
local Itness = request('!.concepts.Codec_Itness')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local table_to_str = request('!.convert.table_to_str')

print(string.format('Reading data from "%s".', Config.input_file_name))
InputFile:Open(Config.input_file_name)

local ItnessTree = Itness:Parse(InputFile)

InputFile:Close()

print(string.format('Writing data to "%s".', Config.output_file_name))
OutputFile:Open(Config.output_file_name)

OutputFile:Write(table_to_str(ItnessTree))

OutputFile:Close()

--[[
  2024 # # # # #
  2026-05-12
  2026-05-23
]]
