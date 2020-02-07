#!/usr/bin/env bash
#
# Generate a dot file to create graph of RERO-ils data (orga, lib and users)
#

# Usage:
#    bash gen.sh output.dot
# where `output.dot` is the output file that permit to generate a graph.
# To generate the graph:
#    dot -Tsvg output.dot -o organisations.svg
# where `output.dot` is the previous file. And `organisations.svg` the final schema you want to display.

# CONFIG
RERO_DIR="${HOME}/projets/rero/rero-ils"
# pastel colors (Cf. https://www.color-hex.com/color-palette/5361)
COLOR1="#ffb3ba"
COLOR2="#ffdfba"
COLOR3="#ffffba"
COLOR4="#baffc9"
COLOR5="#bae1ff"
COMP_COLOR4="#ffd8ba"
# colors you choose for different objects
ORGA_COLOR="${COLOR1}"    # organisations
LIB_COLOR="${COLOR2}"     # libraries
PT_COLOR="${COLOR3}"      # patron_types
USER_COLOR="${COLOR5}"    # users/patrons

# Built variables
outputfile="$1"
SRC_DIR="${RERO_DIR}/data/"
tmpl_gizmo="templates/gizmo.tmpl" # A colored polygon. Represents an entity.
tmpl_link="templates/link.tmpl"   # A link between two entities.
tmpl_label="templates/label_default.tmpl" # Default label for entities.

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
save "templates/header.tmpl"

# ORGANISATIONS
orga_file="${SRC_DIR}organisations.json"
shape="box"
color="${ORGA_COLOR}"
cat "${orga_file}"|jq -c '.[] | { 
  name,
  pid,
  code }'| while read orga
do
  # take important info
  pid=$(echo $orga|jq -r .pid)
  code=$(echo $orga|jq -r .code)
  name=$(echo $orga|jq -r .name)
  # write result in output
  identifier="Orga${pid}"
  label="$(render ${tmpl_label})"
  save "${tmpl_gizmo}"
done

# LIBRARIES
lib_file="${SRC_DIR}libraries.json"
shape="house"
color="${LIB_COLOR}"
cat "${lib_file}"|jq -c '.[] | {
  name,
  pid,
  code,
  organisation: .organisation."$ref"}'|while read lib
do
  pid=$(echo $lib|jq -r .pid)
  name=$(echo $lib|jq -r .name)
  code=$(echo $lib|jq -r .code)
  orga=$(echo $lib|jq -r .organisation)
  orga_pid=$(echo $orga|rev|cut -d "/" -f 1|rev)
  # write result in output
  identifier="Lib${pid}"
  label="$(render ${tmpl_label})"
  save "${tmpl_gizmo}"
  relation="Orga${orga_pid}"
  save "${tmpl_link}"
done

# PATRON_TYPES
pt_file="${SRC_DIR}patron_types.json"
shape="polygon"
color="${PT_COLOR}"
additionals="sides=7"
cat "${pt_file}" |jq -c '.[] | {
  pid,
  name,
  organisation: .organisation."$ref"}'|while read pt
do
  pid=$(echo $pt|jq -r .pid)
  name=$(echo $pt|jq -r .name)
  orga=$(echo $pt|jq -r .organisation)
  # write result in output
  identifier="Type${pid}"
  label="$(render templates/label_patron_types.tmpl)"
  save "${tmpl_gizmo}"

  # Make a link with organisation if present
  if [[ -n "${orga}" ]]; then
    orga_pid=$(echo $orga|rev|cut -d "/" -f 1|rev)
    relation="Orga${orga_pid}"
    save "${tmpl_link}"
  fi
done

# USERS
user_file="${SRC_DIR}users.json"
shape="ellipse"
additionals=''
color="${USER_COLOR}"
cat "${user_file}"|jq -c '.[] | {
  email,
  first_name,
  last_name,
  barcode,
  roles,
  library: .library."$ref",
  pt: .patron_type."$ref"}'|while read user
do
  email=$(echo $user|jq -r .email)
  first_name=$(echo $user|jq -r .first_name)
  last_name=$(echo $user|jq -r .last_name)
  barcode=$(echo $user|jq -r .barcode)
  roles=$(echo $user|jq -r .roles[])
  library=$(echo $user|jq -r .library)
  library_pid=$(echo $library|rev|cut -d "/" -f 1|rev)
  pt=$(echo $user|jq -r .pt)

  # Prepare additional info
  if [[ "${roles}" != "null" ]]; then
    displayed_roles="roles: "
    for role in ${roles}; do
      displayed_roles="${displayed_roles}<font color='red' >${role}</font>, "
    done
  fi
  # Don't display barcode if no one
  info=""
  if [[ "${barcode}" != "null" ]]; then
    info="${info}<br/>${barcode}"
  fi
  # Same for roles
  if [[ -n "${displayed_roles}" ]]; then
    info="${info}<br/>${displayed_roles}"
  fi

  # write result in output
  identifier="User_${email}"
  label="$(render templates/label_users.tmpl)"
  save "${tmpl_gizmo}"

  # Display a link if library_pid is not null
  if [[ "${library_pid}" != "null" ]]; then
    relation="Lib${library_pid}"
    save "${tmpl_link}"
  fi

  # Display a link if patron_type is not null
  if [[ "$pt" != "null" ]]; then
    pt_id=$(echo $pt|rev| cut -d "/" -f 1|rev)
    relation="Type${pt_id}"
    save "${tmpl_link}"
  fi
done

# end of file
save "templates/footer.tmpl"


# END of program
exit 0
