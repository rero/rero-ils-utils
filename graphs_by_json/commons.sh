#!/usr/bin/env bash
#
# COMMONS variables, functions and statements for differents graphs
#

# Built variables
outputfile="$1"
RERO_DIR="${RERO_DIR:-${HOME}/projets/rero/rero-ils}"
SRC_DIR="${RERO_DIR}/data/"

# Templates
tmpl_gizmo="templates/gizmo.tmpl" # A colored polygon. Represents an entity.
tmpl_link="templates/link.tmpl"   # A link between two entities.
tmpl_label="templates/label_default.tmpl" # Default label for entities.

# pastel colors (Cf. https://www.color-hex.com/color-palette/5361)
COLOR1="#ffb3ba"
COLOR2="#ffdfba"
COLOR3="#ffffba"
COLOR4="#baffc9"
COLOR5="#bae1ff"
COMP_COLOR4="#ffd8ba"

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
if [[ ! -d "${RERO_DIR}" ]]; then
  echo "Source directory doesn't exist: ${RERO_DIR}. Did you set RERO_DIR variable?"
  exit 1
fi
if [[ ! -d "${SRC_DIR}" ]]; then
  echo "No data directory found in ${RERO_DIR}. Did you set RERO_DIR variable correctly?"
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
# parse_json: read JSON file (filename given in $1) and applying filter (same name as $1)
parse_json() {
  filepath="${SRC_DIR}/$1.json"
  filter="filters/$1"
  cat "$filepath" | jq -cf "$filter"
}

# Output file initialization
echo "" > "$outputfile" # flush output file
