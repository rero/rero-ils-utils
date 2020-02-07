# Presentation

*gen.sh* generates a diagram with **graphviz** with the link between organisations, libraries and users in *rero-ils* project.

# Requirements

  * graphviz
  * [jq](https://stedolan.github.io/jq/)

# Usage

  * Open **gen.sh** file
  * change **RERO\_DIR** variable to point your **rero-ils directory**

```
make clean && make
```

Result: **organisations.svg** file (can be open with Gimp for example).
