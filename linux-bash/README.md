# Bash & Linux

# Index
- [Load Settings from a file + awk](#load-settings-from-a-file-+-awk)
- [Get the last field with awk](#get-the-last-field-with-awk)
- [System resources stress](system-resources-stress)


## Load Settings from a file + awk

The following sample uses `sed` and `awk` commands for reading a configuration file, parsing the content and loading configurations. In this particular sample the file has some defined properties and may look like:
```
scripts_dir = '/some/path'
zip_name    = 'important-file.zip'
zip_dest    = '/some/other/path'
```
The following script can then be used for picking up the contents:
```
#!/usr/bin/env bash

# Config
cfg_file=/path/to/your/file
tmp_cfg='settings.tmp'

# Read file
sed 's/ //g' $cfg_file | sed 's/\t//g' > $tmp_cfg

# Pick of values
scripts_dir=$(awk -F "=" '/scripts_dir/ {print $2}' $tmp_cfg)
zip_name=$(awk -F "=" '/zip_name/ {print $2}' $tmp_cfg)
zip_dest=$(awk -F "=" '/zip_dest/ {print $2}' $tmp_cfg)

# Do stuff...
...
```

## Get the last field with awk
```
TASK_ID=$(echo $TASK_DETAILS | jq -r '.TaskARN' | awk -F '/' '{print $NF}')
```

## System resources stress
Stress the system memory, filling up-to 90% of the RAM. The ```0.9``` value can be tweaked to fill diferente percentajes of the RAM memory.
```
stress-ng --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1
```
Stress the disks:
```
stress-ng --hdd 4 --timeout 60m /efs/
```

