# DEPENDS ON: Organisations (process_orgas.sh)

# Colors
IT_COLOR="${COLOR4}"      # item_types

# Main configuration
shape="polygon"
color="${IT_COLOR}"
additionals="sides=6"
while read it
do
  pid=$(echo $it|jq -r .pid)
  name=$(echo $it|jq -r .name)
  orga=$(echo $it|jq -r .organisation)
  itype="$(echo $it|jq -r '.type')"
  # write result in output
  identifier="IType${pid}"
  label="$(render templates/label_item_types.tmpl)"
  save "${tmpl_gizmo}"

  # Make a link with organisation if present
  if [[ -n "${orga}" ]]; then
    orga_pid=$(echo $orga|rev|cut -d "/" -f 1|rev)
    relation="Orga${orga_pid}"
    save "${tmpl_link}"
  fi
done <<< $(parse_json "item_types")
