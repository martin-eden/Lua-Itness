#!/bin/bash

# Create "workshop/" directory with needed files from current
# version of "workshop" code hive.

set -eu

cd ..

rm -rf workshop/

lua build/create_deploy.lua

bash deploy.sh
rm deploy.sh

mv deploy/workshop .
rm -rf deploy/
