-- Lua to Itness

-- Last mod.: 2024-10-21

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local InputFileName = 'Tree.lua'
local OutputFileName = 'Tree.is'

-- ( Imports
local FileAsString = request('!.file_system.file.as_string')
local StringToTable = request('!.concepts.lua_table_code.load')
-- local TableToString = request('!.concepts.lua_table_code.save')
local Writer = request('!.concepts.StreamIo.Output.File')
local Serializer = request('Itness.Serializer.Interface')
-- ) Imports

print(string.format('Loading data from "%s".', InputFileName))

local DataStr = FileAsString(InputFileName)
local Sequence = StringToTable(DataStr)

-- print(TableToString(Sequence))

Writer:OpenFile(OutputFileName)

print(string.format('Writing results to "%s".', OutputFileName))

Serializer.Output = Writer
Serializer:Run(Sequence)

Writer:CloseFile()

--[[
  2024-08-04
  2024-09-04
  2024-10-20
  2024-10-21
]]
