-- Itness to Itness

--[[
  Author: Martin Eden
  Last mod.: 2026-11-13
]]

require('workshop.base')

local input_file_name = arg[1]
local output_file_name = arg[2]

assert(input_file_name)
assert(output_file_name)

local str_format = string.format

local itness_node

print(str_format('Reading data from "%s".', input_file_name))
do
  local input_file_class = request('!.concepts.streams.input.file')
  local itness_parse = request('!.concepts.codec_itness.parse')
  local input_file = input_file_class.create(input_file_name)
  input_file:open()
  itness_node = itness_parse(input_file)
  input_file:close()
end

print(str_format('Writing results to "%s".', output_file_name))
do
  local output_file_class = request('!.concepts.streams.output.file')
  local itness_compile = request('!.concepts.codec_itness.compile')
  local output_file = output_file_class.create(output_file_name)
  output_file:open()
  itness_compile(itness_node, output_file)
  output_file:close()
end

--[[
  2026-09-23
]]
