# Bash & Linux

# Index
- [Bash script - validate that is not already running](bash-script-|-validate-that-is-not-already-running)
- [Bash script - sanity checks](bash-script---sanity-checks)
- [Get the last field with awk](#get-the-last-field-with-awk)
- [grep simple text matching](grep-simple-text-matching)
- [Load settings from a file with awk](#load-settings-from-a-file-with-awk)
- [System resources stress](system-resources-stress)

****

## Bash script | validate that is not already running
Many times, especially with cron-jpbs that run very often it is important to validate that there is only one instance of the script running at any given time. Some scripts performing atomic or synchronisation tasks may collision if there are two instances of the same scrip running at the same time. A very simple sample can be synchronising files from S3 buckets. You may want to have frequent sync (a cron-job running every 5 minutes), but if there is already a synchronisation job taking place, you don’t want to overlap them. 
```
#!/usr/bin/env bash
script_name=$(basename -- "$0")
s3_bucket_to_sync='some-s3-bucket-name'
s3_bucket_subdirectory='some/path/'

##
# Check if the script is already running ...
if pidof -x "$script_name" -o $$ >/dev/null; then
   echo "An another instance of this script is already running."
   exit 1
fi

##
# If not... continue...

##
# Check if there are files in s3 to sync...
echo -e 'Checking $s3_bucket_to_sync bucket...'
aws s3 ls --summarize $s3_bucket_to_sync/$s3_bucket_subdirectory | grep 'Total Size: 0'
if [ $? -eq 0 ]
then
      echo -e "Bucket path empty... nothing to sync."
      exit 0
fi

##
# Not empty... sync
echo -e "Sync files from S3...
# //TODO
```

## Bash script - sanity checks

Sample script that performs sanity checks and verifies if given commands exist before proceeding. It also creates an alias for OS inter-compatibility (MacOS/Linux).

```
#!/usr/bin/env bash

# 1. Sanity checks

if ! command -v aws &> /dev/null
then
    echo "'aws' may not be installed, please double check it."

elif ! command -v sha256sum &> /dev/null
then
    echo "Looking for alternative 'shasum' commands..."

    if ! command -v shasum &> /dev/null
    then
        echo "'shasum' could not be found in any variant, please install it."
        exit 1

    else
        alias sha256sum='shasum -a 256'
    fi

elif ! command -v zip &> /dev/null
then
    echo "'zip' could not be found, please install it."
    exit 1

fi

## Do stuff...
```


## Get the last field with awk
```
TASK_ID=$(echo $TASK_DETAILS | jq -r '.TaskARN' | awk -F '/' '{print $NF}')
```


## [grep](https://linux.die.net/man/1/grep) simple text matching

The ```grep``` command is a very powerful tool that can help us to find matching patterns, keywords or even phrases across a large number of files. While using the flags ```-r``` for recursion and ```-n``` for printing line numbers, we can easily find occurrences of a given string across an entire directory. Much more complex searches can be done with regular expressions.
```
grep -nR "keyword" ./*
```


## Load settings from a file with awk

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


## System resources stress
Stress the system memory, filling up-to 90% of the RAM. The ```0.9``` value can be tweaked to fill diferente percentajes of the RAM memory.
```
stress-ng --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1
```
Stress the disks:
```
stress-ng --hdd 4 --timeout 60m /efs/
```

