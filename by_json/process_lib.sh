# DEPENDS ON: Organisations (process_orgas.sh)

# Colors
LIB_COLOR="${COLOR2}"     # libraries

# Main configuration
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
