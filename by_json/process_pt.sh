# DEPENDS ON: Organisations (process_orgas.sh)

# Colors
PT_COLOR="${COLOR3}"      # patron_types

# Main configuration
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
