-- Load modules, get list of all required Lua files, copy them

--[[
  Author: Martin Eden
  Last mod.: 2026-11-13
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

local modules = { 'recode_is' }
arg[1] = '../samples/it.is'
arg[2] = '../samples/recoded.it.is'

--
package.path = package.path .. ';../../../?.lua'
--
local module_paths
do
  local observe_modules = require('workshop.system.observe_modules')
  module_paths = observe_modules(modules)
end
--
require('workshop.base')

local files = { }
do
  local add_to = request('!.concepts.list.add_item')
  for _, module_loc in ipairs(module_paths) do
    add_to(files, module_loc[2])
  end
end

local deploy = request('!.mechs.deploy')

deploy(files)
--

--[[
  202?
  2026 # # # #
  2026-09-24
]]
