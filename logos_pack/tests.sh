#!/usr/bin/env bash

# Config.
DIR=$(cd `dirname $0` && pwd)

# Process
cd "${DIR}"
make clean && make
# return to initial directory
cd -

# Tests
# Check if `static.tar.gz` exists
file_static="${DIR}/static.tar.gz"
if ! [[ -f "${file_static}" ]]; then
  echo "ERROR: ${file_static} missing!"
  exit 1
else
  echo "SUCCESS: ${file_static} found."
fi
# end
exit 0
