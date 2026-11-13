#!/bin/sh

# Pack function into one Lua code file

#
# Author: Martin Eden
# Last mod.: 2026-11-13
#

#
# Results are placed in "deploy/"
#
# We will create file "recode_is.lua" there.
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

lua ../builder/deploy.lua

mv deploy/workshop/ .
rm -r -f deploy/

#
# builder/
#

cd ../builder

# Combine all Lua code
./meld ../src/ recode_is > ../deploy/recode_is.melded.lua

# Reformat code and strip comments
./reformat_lua \
  ../deploy/recode_is.melded.lua \
  ../deploy/recode_is.melded.stripped.lua \
  --right-margin=72
rm ../deploy/recode_is.melded.lua


# Add shebang
echo '#!/usr/local/bin/lua'"\n" > ../deploy/recode_is.melded.stripped.shebanged.lua
cat ../deploy/recode_is.melded.stripped.lua >> ../deploy/recode_is.melded.stripped.shebanged.lua
rm ../deploy/recode_is.melded.stripped.lua

mv \
  ../deploy/recode_is.melded.stripped.shebanged.lua \
  ../deploy/recode_is

# Mark as executable
chmod +x ../deploy/recode_is

#
# /
#

cd ..

# Test
deploy/recode_is samples/it.is samples/recoded.it.is

# 2026 # # # # #
# 2026-09-23
