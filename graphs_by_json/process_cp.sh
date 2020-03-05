# DEPENDS ON: Organisations (process_orgas.sh), Libraries (process_lib.sh)

# Main configuration
while read cp
do
  # main info
  pid=$(echo $cp|jq -r .pid)
  name=$(echo $cp|jq -r .name)
  description=$(echo $cp|jq -r .description)
  orga=$(echo $cp|jq -r .organisation)

  # Additional info
  checkout=$(echo $cp|jq -r .allow_checkout)
  duration=$(echo $cp|jq -r .checkout_duration)
  requests=$(echo $cp|jq -r .allow_requests)
  library_level=$(echo $cp|jq -r .policy_library_level)

  # reset values (because settings overwrites them)
  shape="doubleoctagon"
  color="${COLOR5}"
  border_color="${COLOR5}"
  additionals=""
  # write result in output
  identifier="CP${pid}"
  label="$(render templates/label_circulation_policies.tmpl)"
  save "${tmpl_gizmo}"

  # Make a link with organisation if present
  if [[ -n "${orga}" ]]; then
    orga_pid=$(echo $orga|rev|cut -d "/" -f 1|rev)
    relation="Orga${orga_pid}"
    save "${tmpl_link}"
  fi

  # Parse settings (if have content)
  settings=$(echo $cp|jq -r .settings)
  if [[ "${settings}" != "null" ]]; then
    for setting in $(echo $settings|jq -c '.[]')
    do
      pt_pid=$(echo $setting|jq -r '.patron_type."$ref"'|rev| cut -d"/" -f1 |rev)
      it_pid=$(echo $setting|jq -r '.item_type."$ref"'|rev|cut -d"/" -f1|rev)

      # reset values
      shape="Mrecord"
      color="${COLOR4}"
      border_color="black"
      additionals=""
      # write result in output
      identifier="Setting${pid}${pt_pid}${it_pid}"
      label=$(render templates/label_settings.tmpl)
      save "${tmpl_gizmo}"

      # Make a link between setting and Circulation Policy
      relation="CP${pid}"
      save "${tmpl_link}"
    done
  fi

done <<< $(parse_json "circulation_policies")
