-- Lua table to Itness

-- Last mod.: 2024-10-20

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local FileAsString = request('!.file_system.file.as_string')
local StringToTable = request('!.concepts.lua_table_code.load')
local Sequencer = request('Sequencer.Interface')
-- local TableToString = request('!.concepts.lua_table_code.save')
local Writer = request('!.concepts.StreamIo.Output.File')
local Serialize = request('Itness.Serialize')

local InputFileName = 'It.is.Table.lua'
local OutputFileName = 'Table.is'

print(string.format('Loading data from "%s".', InputFileName))

local DataStr = FileAsString(InputFileName)
local Data = StringToTable(DataStr)

-- print(TableToString(Data))

local Sequence = Sequencer.TableToSeq(Data)

-- print(TableToString(Sequence))

Writer:OpenFile(OutputFileName)

print(string.format('Writing results to "%s".', OutputFileName))

Serialize(Sequence, Writer)

Writer:CloseFile()

--[[
  2024-08-04
  2024-09-04
  2024-10-20
]]
