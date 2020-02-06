#!/usr/bin/env bash

# Generate a dot file to create digraph of RERO-ils data

output="$1"
source="/home/od/projets/rero/rero-ils/data/"

# start of file
echo "digraph {" > "$output"

# ORGANISATIONS
orga_file="${source}organisations.json"
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
  echo "Orga${pid} [label=\"${name}\"]" >> "$output"
done

# LIBRARIES
lib_file="${source}libraries.json"
cat "${lib_file}"|jq -c '.[] | {
  name,
  pid,
  organisation: .organisation."$ref"}'|while read lib
do
  pid=$(echo $lib|jq -r .pid)
  name=$(echo $lib|jq -r .name)
  orga=$(echo $lib|jq -r .organisation)
  orga_pid=$(echo $orga|rev|cut -d "/" -f 1|rev)
  # write result in output
  l_id="Lib${pid}"
  echo "${l_id} [label=\"${name}\"]" >> "$output"
  echo "${l_id} -> Orga${orga_pid}" >> "$output"
done

# USERS
user_file="${source}users.json"
cat "${user_file}"|jq -c '.[] | {
  email,
  first_name,
  last_name,
  library: .library."$ref"} | select(.library |length >= 1)'|while read user
do
  email=$(echo $user|jq -r .email)
  first_name=$(echo $user|jq -r .first_name)
  last_name=$(echo $user|jq -r .last_name)
  library=$(echo $user|jq -r .library)
  library_pid=$(echo $library|rev|cut -d "/" -f 1|rev)
  # write result in output
  u_id="User_${email}"
  echo "\"${u_id}\" [label=\"${first_name} ${last_name}\"]" >> "$output"
  echo "\"${u_id}\" -> Lib${library_pid}" >> "$output"
done

# end of file
echo "}" >> "$output"


# END of program
exit 0
