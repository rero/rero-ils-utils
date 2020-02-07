#!/usr/bin/env bash
#
# Generate a dot file to create graph of RERO-ils data
#

# CONFIG
RERO_DIR="${HOME}/projets/rero/rero-ils"

# Load commons variables, functions and statements
source commons.sh

# Graph header
title="Circulation policies details."
save "templates/header.tmpl"

# ORGANISATIONS
source process_orgas.sh
# LIBRARIES
source process_lib.sh
# CIRCULATION POLICIES
source process_cp.sh

# Graph footer
save "templates/footer.tmpl"

# END of program
exit 0
