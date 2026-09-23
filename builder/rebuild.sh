#!/bin/sh

# Pack function into one Lua code file

#
# Author: Martin Eden
# Last mod.: 2026-09-23
#

#
# Results are placed in "deploy/"
#
# We will create file "RecodeIs.lua" there.
# It's combined Lua code without comments.
#
# Toolchain uses my "lua code melder" tool to combine files into one:
#
#   https://github.com/martin-eden/lua_code_melder
#
# Toolchain uses my "lua code formatter" tool to strip comments:
#
#   https://github.com/martin-eden/lua_code_formatter
#

set -e -u

#
# src/
#

cd ../src

rm -r -f workshop/

lua ../builder/create_deploy.lua

bash deploy.sh
rm deploy.sh

mv deploy/workshop/ .
rm -r -f deploy/

#
# builder/
#

cd ../builder

# Combine all Lua code
./meld ../src/ RecodeIs > ../deploy/RecodeIs.melded.lua

# Reformat code and strip comments
./reformat_lua \
  ../deploy/RecodeIs.melded.lua \
  ../deploy/RecodeIs.melded.stripped.lua \
  --~keep-comments \
  --right-margin=72
rm ../deploy/RecodeIs.melded.lua

mv \
  ../deploy/RecodeIs.melded.stripped.lua \
  ../deploy/RecodeIs.lua

#
# /
#

cd ..

# Test
lua deploy/RecodeIs.lua samples/it.is samples/recoded.it.is

# 2026 # # # # #
# 2026-09-23

