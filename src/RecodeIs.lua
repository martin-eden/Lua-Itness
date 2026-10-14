-- Itness to Itness

--[[
  Author: Martin Eden
  Last mod.: 2026-10-14
]]

--[[
  Used as test

  Because serializing table to Lua code is another module
  that weights more than this codec.
]]

--[[ Develop
package.path = package.path .. ';../../../?.lua'
--]]
require('workshop.base')

local input_file_name = arg[1]
local output_file_name = arg[2]

assert(input_file_name)
assert(output_file_name)

local str_format = string.format

local InputFile
local ItnessNode
local OutputFile

print(str_format('Reading data from "%s".', input_file_name))
do
  local InputFileClass = request('!.concepts.StreamIo.Input.File')
  local itness_parse = request('!.concepts.codec_itness.parse')
  InputFile = InputFileClass.create(input_file_name)
  InputFile:Open()
  ItnessNode = itness_parse(InputFile)
  InputFile:Close()
end

print(str_format('Writing results to "%s".', output_file_name))
do
  local OutputFileClass = request('!.concepts.StreamIo.Output.File')
  local itness_compile = request('!.concepts.codec_itness.compile')
  OutputFile = OutputFileClass.create(output_file_name)
  OutputFile:Open()
  itness_compile(ItnessNode, OutputFile)
  OutputFile:Close()
end

--[[
  2026-09-23
]]
