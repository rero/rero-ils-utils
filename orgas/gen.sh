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

# Load commons variables, functions and statements
source commons.sh

# Graph header
title="Link between organisations, libraries and users."
save "templates/header.tmpl"

# ORGANISATIONS
shape="box"
color="${ORGA_COLOR}"
while read -r orga
do
  # take important info
  pid=$(echo $orga|jq -r .pid)
  code=$(echo $orga|jq -r .code)
  name=$(echo $orga|jq -r .name)
  # write result in output
  identifier="Orga${pid}"
  label="$(render ${tmpl_label})"
  save "${tmpl_gizmo}"
done <<< $(parse_json "organisations")

# LIBRARIES
shape="house"
color="${LIB_COLOR}"
while read -r lib
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
done <<< $(parse_json "libraries")

# PATRON_TYPES
shape="polygon"
color="${PT_COLOR}"
additionals="sides=7"
while read pt
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
done <<< $(parse_json "patron_types")

# USERS
shape="ellipse"
additionals=''
color="${USER_COLOR}"
while read user
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
done <<< $(parse_json "users")

# Graph footer
save "templates/footer.tmpl"

# END of program
exit 0
