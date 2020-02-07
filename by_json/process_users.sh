# DEPENDS ON: Patron types (process_pt.sh), Library (process_lib.sh)

# Colors
USER_COLOR="${COLOR5}"    # users/patrons

# Main configuration
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
