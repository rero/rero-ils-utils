#!/usr/bin/env bash
#
# COMMONS variables, functions and statements for differents graphs
#

# Built variables
outputfile="$1"
SRC_DIR="${RERO_DIR}/data/"

# Templates
tmpl_gizmo="templates/gizmo.tmpl" # A colored polygon. Represents an entity.
tmpl_link="templates/link.tmpl"   # A link between two entities.
tmpl_label="templates/label_default.tmpl" # Default label for entities.

# Graph info
rankdir="RL"
title=""

# TESTS
if [[ -z "${outputfile}" ]]; then
  echo "No output file given"
  exit 1
elif [[ -f "${outputfile}" ]]; then
  echo "File already exists!"
  exit 1
fi

# FUNCTIONS
# WRITE first argument in output file
send() {
  echo -e "$1" >> "$outputfile"
}
# render: SHOW template (given in $1) after variables REPLACEMENTS
render() {
  template="$(cat $1)"
  eval "echo -e \"${template}\""
}
# save: WRITE template (given in $1) in outputfile after variables REPLACEMENTS
save() {
  rendered_template="$(render $1)"
  send "${rendered_template}"
}

# Output file initialization
echo "" > "$outputfile" # flush output file
