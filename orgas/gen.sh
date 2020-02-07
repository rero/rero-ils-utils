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
output="$1"
SRC_DIR="${RERO_DIR}/data/"

# TESTS
if [[ -z "${output}" ]]; then
  echo "No output file given"
  exit 1
elif [[ -f "${output}" ]]; then
  echo "File already exists!"
  exit 1
fi

# start of file
echo "digraph {" > "$output"
echo "rankdir = RL;" >> "$output"
echo "label = \"Link between organisations, libraries and users.\";" >> "$output"

# ORGANISATIONS
orga_file="${SRC_DIR}organisations.json"
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
  echo "Orga${pid} [shape=box color=\"transparent\" style=filled fillcolor=\"${ORGA_COLOR}\" label=<${name}<br/>(code: ${code})>]" >> "$output"
done

# LIBRARIES
lib_file="${SRC_DIR}libraries.json"
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
  l_id="Lib${pid}"
  echo "${l_id} [shape=house color=transparent style=filled fillcolor=\"${LIB_COLOR}\" label=<${name}<br/>(code: ${code})>]" >> "$output"
  echo "${l_id} -> Orga${orga_pid}" >> "$output"
done

# PATRON_TYPES
pt_file="${SRC_DIR}patron_types.json"
cat "${pt_file}" |jq -c '.[] | {
  pid,
  name,
  organisation: .organisation."$ref"}'|while read pt
do
#  # The char " is problematic. Delete it.
#  pt=$(echo $pt| sed -e 's/^"//g' -e 's/"$//g')
#  pid=$(echo $pt|cut -d "|" -f 1)
#  name=$(echo $pt|cut -d "|" -f 2)
#  orga=$(echo $pt|cut -d "|" -f 3)
  pid=$(echo $pt|jq -r .pid)
  name=$(echo $pt|jq -r .name)
  orga=$(echo $pt|jq -r .organisation)
  # write result in output
  p_id="Type${pid}"
  echo "${p_id} [shape="polygon" sides=7 color=transparent style=filled fillcolor=\"${PT_COLOR}\" label=\"${name}\"]" >> "$output"
  # Make a link with organisation if present
  if [[ -n "${orga}" ]]; then
    orga_pid=$(echo $orga|rev|cut -d "/" -f 1|rev)
    echo "${p_id} -> Orga${orga_pid}" >> "$output"
  fi
done

# USERS
user_file="${SRC_DIR}users.json"
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

  if [[ "${roles}" != "null" ]]; then
    displayed_roles="roles: "
    for role in ${roles}; do
      displayed_roles="${displayed_roles}<font color='red' >${role}</font>, "
    done
  fi
  # write result in output
  u_id="User_${email}"

  # Don't display barcode if no one
  info=""
  if [[ "${barcode}" != "null" ]]; then
    info="${info}<br/>${barcode}"
  fi
  # Same for roles
  if [[ -n "${displayed_roles}" ]]; then
    info="${info}<br/>${displayed_roles}"
  fi

  echo "\"${u_id}\" [color=transparent style=filled fillcolor=\"${USER_COLOR}\" label=<${first_name} ${last_name}<br/>${email}${info}>]" >> "$output"

  # Display a link if library_pid is not null
  if [[ "${library_pid}" != "null" ]]; then
    echo "\"${u_id}\" -> Lib${library_pid}" >> "$output"
  fi

  # Display a link if patron_type is not null
  if [[ "$pt" != "null" ]]; then
    pt_id=$(echo $pt|rev| cut -d "/" -f 1|rev)
    echo "\"${u_id}\" -> Type${pt_id}" >> "$output"
  fi
done

# end of file
echo "}" >> "$output"


# END of program
exit 0
