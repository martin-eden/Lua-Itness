-- [Template] Load modules to get a list of all required Lua files

--[[
  Author: Martin Eden
  Last mod.: 2026-04-24
]]

--[[
  How to use

  * Place at directory with main Lua source file
  * Include that file as a module in <ModulesList>
  * Run this one

  Make sure that main Lua file executes without errors when
  loaded as module. If needed, make changes to it to behave so.

  At loading via request() module dependencies are stored in
  some global table. create_deploy_script() uses that table to
  write Bash script which copies module files to local directory.
]]

package.path = package.path .. ';../../?.lua'
require('workshop.base')

local create_deploy_script = request('!.system.create_deploy_script')

local ModulesList =
  {
    'workshop.base',
    'Compile',
    'Parse',
  }

create_deploy_script(ModulesList)

--[[
  202?
  2026-01-21
  2026-04-23
]]
