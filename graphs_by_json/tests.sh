#!/usr/bin/env bash

# Config.
DIR=$(cd `dirname $0` && pwd)
RERO_DIR="${DIR}/rero-ils"
DATE=`date +'%Y%m%d'`

# Checks
if [[ -d "${RERO_DIR}" ]]; then
  rm -rf "${RERO_DIR}"
fi

# Process
git clone --branch dev --depth=1 https://github.com/rero/rero-ils "${RERO_DIR}"
cd "${DIR}"
make clean && RERO_DIR="${RERO_DIR}" make
# return to initial directory
cd -

# Tests
# Check if `*-policies.svg` exists
file_policies="${DIR}/${DATE}-policies.svg"
if ! [[ -f "${file_policies}" ]]; then
  echo "ERROR: ${file_policies} missing!"
  exit 1
else
  echo "SUCCESS: ${file_policies} found."
fi
file_orgas="${DIR}/${DATE}-orgas.svg"
if ! [[ -f "${file_orgas}" ]]; then
  echo "ERROR: ${file_orgas} missing!"
  exit 1
else
  echo "SUCCESS: ${file_orgas} found."
fi
# end
exit 0
