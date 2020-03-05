# DEPENDS ON: None

# Colors
ORGA_COLOR="${COLOR1}"    # organisations

# Main configuration
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
