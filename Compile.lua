-- Lua to Itness

--[[
  Author: Martin Eden
  Last mod.: 2026-05-26
]]

--[[ Develop
package.path = package.path .. ';../../?.lua'
--]]
require('workshop.base')

local Config =
  {
    input_file_name = 'Tree.lua',
    output_file_name = 'Tree.is',
  }

-- Imports:
local file_to_str = request('!.convert.file_to_str')
local table_from_str = request('!.convert.table_from_str')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local Itness = request('!.concepts.Codec_Itness.Interface')

print(string.format('Loading data from "%s".', Config.input_file_name))
local DataStr = file_to_str(Config.input_file_name)

local ItnessTree = table_from_str(DataStr)

print(string.format('Writing results to "%s".', Config.output_file_name))
OutputFile:Open(Config.output_file_name)

Itness:Compile(ItnessTree, OutputFile)

OutputFile:Close()

--[[
  2024 # # # #
  2026-05-11
  2026-05-23
]]
