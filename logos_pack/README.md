# HOWTO

1. Modify **ils** directory (adds CSS, removes CSS, modifies CSS, etc.)
2. Launch this command:

```
make clean && make
```

It will generates:

  * static.tar.gz: files for all rero-ils instances
  * static-pilot.tar.gz: files for rero-ils **pilot** instance (with a specific logo-global.png file)

Each **.tar.gz** file will contains:
  * *css* directory with all CSS files
  * *images* directory with pictures (for static-pilot.tar.gz, the **logo-global.png** is those from **logo-global.pilot.png in current directory**)

Note: The script will transform each **resources.rero.ch** URL by another one. `resources.rero.ch/ils/test` for *static.tar.gz* file and `resources.rero.ch/ils/pilot` for *static-pilot.tar.gz* one.
