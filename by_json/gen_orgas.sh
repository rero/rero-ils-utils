#!/usr/bin/env bash
#
# Generate a dot file to create graph of RERO-ils data
#

# Usage:
#    bash gen_orgas.sh output.dot
# where `output.dot` is the output file that permit to generate a graph.
# To generate the graph:
#    dot -Tsvg output.dot -o organisations.svg
# where `output.dot` is the previous file. And `organisations.svg` the final schema you want to display.

# CONFIG
RERO_DIR="${HOME}/projets/rero/rero-ils"

# Load commons variables, functions and statements
source commons.sh

# Graph header
title="Link between organisations, libraries and users."
save "templates/header.tmpl"

# ORGANISATIONS
source process_orgas.sh

# LIBRARIES
source process_lib.sh

# PATRON_TYPES
source process_pt.sh

# USERS
source process_users.sh

# Graph footer
save "templates/footer.tmpl"

# END of program
exit 0
