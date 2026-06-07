-- Lua to Itness

--[[
  Author: Martin Eden
  Last mod.: 2026-06-07
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
local itness_compile = request('!.concepts.codec_itness.compile')

print(string.format('Loading data from "%s".', Config.input_file_name))
local input_str = file_to_str(Config.input_file_name)

local ItnessTree = table_from_str(input_str)

print(string.format('Writing results to "%s".', Config.output_file_name))
do
  OutputFile:Open(Config.output_file_name)
  itness_compile(ItnessTree, OutputFile)
  OutputFile:Close()
end

--[[
  2024 # # # #
  2026-05 # #
  2026-06-07
]]
