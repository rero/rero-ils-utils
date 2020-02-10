# Presentation

*gen_orgas.sh* generates a diagram with **graphviz** with the link between organisations, libraries and users in *rero-ils* project.

*gen_policies.sh* do the same with link between organisations, libraries, circulation policies and patron\_type/item\_type couples.

# Requirements

  * graphviz
  * [jq](https://stedolan.github.io/jq/)

# Usage

  * change **RERO\_DIR** variable to point your **rero-ils directory**

```
make clean && RERO_DIR="/home/moi/rero/rero-ils" make
```

Result: **2 files (orgas.svg and policies.svg)** file (can be open with Gimp for example).
