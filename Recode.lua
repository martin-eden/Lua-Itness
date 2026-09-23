-- Itness to Itness

--[[
  Author: Martin Eden
  Last mod.: 2026-09-23
]]

--[[
  Used as test

  Because serializing table to Lua code is another module
  that weights more than this codec.
]]

--[[ Develop
package.path = package.path .. ';../../?.lua'
--]]
require('workshop.base')

local input_file_name = arg[1] or 'it.is'
local output_file_name = arg[2] or 'recoded.it.is'

local InputFile = request('!.concepts.StreamIo.Input.File')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local itness_parse = request('!.concepts.codec_itness.parse')
local itness_compile = request('!.concepts.codec_itness.compile')

local str_format = string.format

local ItnessNode

print(str_format('Reading data from "%s".', input_file_name))
do
  InputFile:Open(input_file_name)
  ItnessNode = itness_parse(InputFile)
  InputFile:Close()
end

print(str_format('Writing results to "%s".', output_file_name))
do
  OutputFile:Open(output_file_name)
  itness_compile(ItnessNode, OutputFile)
  OutputFile:Close()
end

--[[
  2026-09-23
]]
