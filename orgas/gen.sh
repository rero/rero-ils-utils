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
ORGA_COLOR="#bcafff"
LIB_COLOR="#49afff"

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

# USERS
user_file="${SRC_DIR}users.json"
cat "${user_file}"|jq -c '.[] | {
  email,
  first_name,
  last_name,
  barcode,
  roles,
  library: .library."$ref"}'|while read user
do
  email=$(echo $user|jq -r .email)
  first_name=$(echo $user|jq -r .first_name)
  last_name=$(echo $user|jq -r .last_name)
  barcode=$(echo $user|jq -r .barcode)
  roles=$(echo $user|jq -r .roles[])
  library=$(echo $user|jq -r .library)
  library_pid=$(echo $library|rev|cut -d "/" -f 1|rev)

  if [[ "${roles}" != "null" ]]; then
    displayed_roles=""
    for role in ${roles}; do
      color="black"
      if [[ "${role}" == "system_librarian" ]]; then
        color="${ORGA_COLOR}"
      elif [[ "${role}" == "librarian" ]]; then
        color="${LIB_COLOR}"
      fi
      displayed_roles="${displayed_roles}<font color='${color}'>${role}</font> "
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

  echo "\"${u_id}\" [label=<${first_name} ${last_name}<br/>${email}${info}>]" >> "$output"

  # Display a link if library_pid is not null
  if [[ "${library_pid}" != "null" ]]; then
    echo "\"${u_id}\" -> Lib${library_pid}" >> "$output"
  fi
done

# end of file
echo "}" >> "$output"


# END of program
exit 0
