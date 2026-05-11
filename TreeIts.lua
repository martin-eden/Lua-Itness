-- Lua to Itness

--[[
  Author: Martin Eden
  Last mod.: 2026-05-12
]]

--[[ Develop
package.path = package.path .. ';../../?.lua'
--]]
require('workshop.base')

local InputFileName = 'Tree.lua'
local OutputFileName = 'Tree.is'

-- Imports:
local FileAsString = request('!.convert.file_to_str')
local StringToTable = request('!.convert.table_from_str')
local OutputFile = request('!.concepts.StreamIo.Output.File')
local Serializer = request('Itness.Serializer.Interface')
--[[ Debug
_G.t2s = request('!.convert.table_to_str')
--]]

print(string.format('Loading data from "%s".', InputFileName))

local DataStr = FileAsString(InputFileName)
local ItnessTree = StringToTable(DataStr)

OutputFile:Open(OutputFileName)

print(string.format('Writing results to "%s".', OutputFileName))

Serializer.Output = OutputFile
Serializer:Run(ItnessTree)

OutputFile:Close()

--[[
  2024 # # # #
  2026-05-11
]]
