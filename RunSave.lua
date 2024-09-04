-- Compiler test rig

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local DataModuleName = 'Data'
print(string.format('Loading data from "%s.lua".', DataModuleName))

local Data = request(DataModuleName)

local Sequencer = request('Sequencer.Interface')

local TableToString = request('!.concepts.lua_table_code.save')

-- print(TableToString(Data))

local Sequence = Sequencer.TableToSeq(Data)

-- print(TableToString(Sequence))

local Writer = request('!.concepts.StreamIo.Output.File')

local FileName = 'Data.is'
Writer:OpenFile(FileName)

print(string.format('Writing results to "%s".', FileName))

local Serialize = request('Save')

Serialize(Sequence, Writer)

Writer:CloseFile()

--[[
  2024-08-04
  2024-09-04
]]
