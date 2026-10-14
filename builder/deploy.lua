-- Load modules, get list of all required Lua files, copy them

--[[
  Author: Martin Eden
  Last mod.: 2026-10-14
]]

--[[
  How to use

  * Include root modules in <Modules>

  * Do one of

    * Copy this file to root Lua source directory

    * Call this file from Lua source directory:

        $ lua ../builder/deploy.lua

  Make sure that main Lua file executes without errors when
  loaded as module. If needed, make changes to it to behave so.
]]

local Modules = { 'RecodeIs' }
arg[1] = '../samples/it.is'
arg[2] = '../samples/recoded.it.is'

--
package.path = package.path .. ';../../../?.lua'
--
local ModulePaths
do
  local observe_modules = require('workshop.system.observe_modules')
  ModulePaths = observe_modules(Modules)
end
--
require('workshop.base')

local FilesList
do
  local add_to = request('!.concepts.list.add_item')
  FilesList = { }
  for _, ModuleLoc in ipairs(ModulePaths) do
    add_to(FilesList, ModuleLoc[2])
  end
end

local deploy = request('!.mechs.deploy')

deploy(FilesList)
--

--[[
  202?
  2026 # # # #
  2026-09-24
]]
