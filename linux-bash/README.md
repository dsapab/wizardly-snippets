# Bash & Linux

# Index
- [Networking](#networking)
  - [ip](#ip)
  - [nmcli / nmtui](#nmcli--nmtui)
  - [ss](#ss)
  - [netplan](#netplan)
- [Package management](#package-management)
  - [dnf](#dnf)
  - [apt](#apt)
- [System administration](#system-administration)
  - [System resources stress](#system-resources-stress)
- [Binary inspection & tracing](#binary-inspection--tracing)
  - [readelf - ELF structure](#readelf---elf-structure)
  - [nm - symbol lister](#nm---symbol-lister)
  - [objdump - disassembler](#objdump---disassembler)
  - [strace - trace syscalls](#strace---trace-syscalls)
  - [ltrace - trace library calls](#ltrace---trace-library-calls)
  - [perf - low-overhead tracing](#perf---low-overhead-tracing)
- [Files & text processing](#files--text-processing)
  - [rsync](#rsync)
  - [grep simple text matching](#grep-simple-text-matching)
  - [Get the last field with awk](#get-the-last-field-with-awk)
- [Scripting](#scripting)
  - [Bash script - validate that is not already running](#bash-script---validate-that-is-not-already-running)
  - [Bash script - sanity checks](#bash-script---sanity-checks)
  - [Load settings from a file with awk](#load-settings-from-a-file-with-awk)
  - [Makefiles](#makefiles)

****
## Networking

### ip
Show interfaces with their IP address configuration:
```
ip addr show
```
Show the default route:
```
ip route show
```
Show NICs:
```
ip link show
```
Show interface statistics (RX/TX counters, cumulative since boot):
```
ip -s link show          # stats for all interfaces
ip -s link show eth0     # one interface
ip -s -s link show eth0  # -s twice adds a per-error breakdown
```
The counters come in an RX (inbound) block and a TX (outbound) block. `bytes`/`packets` are just volume. The diagnostic ones are `errors` (malformed frames, points at cabling or a failing NIC), `dropped` (kernel discarded the frame, RX drops mean it could not keep up), `overrun` (NIC ring buffer overflowed before the kernel drained it, pairs with high `si` softirq load), and `carrier`/`collsns` on TX (link flapping or a duplex mismatch). On a healthy link everything except `bytes`/`packets`/`mcast` sits at or near zero, so anything climbing is the lead.

The `-s -s` form splits errors into kinds (`crc`, `frame`, `fifo`, `missed`, ...), which routes the fix. CRC points at physical corruption (replace the cable), `fifo`/`missed` at the ring buffer overflowing (tune ring buffers or IRQ affinity).

Related, for deeper NIC-level detail:
```
ethtool -S eth0          # driver-level counters (rx_crc_errors, rx_missed_errors, ...)
ethtool eth0             # link speed, duplex, autoneg (duplex-mismatch check)
cat /proc/net/dev        # raw counters ip reads, all interfaces in one table
```

### nmcli / nmtui
Interact with NetworkManager from the CLI:
```
nmcli
```
Interact with NetworkManager via the text UI:
```
nmtui
```

### ss
List all sockets and connections:
```
ss -tunap
```

### netplan
_Ubuntu default (server 18.04+)._ Debian does not use netplan by default. Standard Debian installs configure interfaces with ifupdown in `/etc/network/interfaces`, driven by `ifup` / `ifdown`.

On Ubuntu, persistent interface config lives in `/etc/netplan/*.yaml` (runtime tweaks still use `ip`).
```
sudo netplan apply   # apply config changes
sudo netplan try     # apply with auto-rollback if connectivity is lost
networkctl status    # query state (systemd-networkd backend)
```
A minimal `/etc/netplan/01-netcfg.yaml` for a static address:
```
network:
  version: 2
  ethernets:
    eth0:
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```


## Package management

### dnf
_RHEL / Fedora family._

Get the full manual pages:
```
sudo dnf install -y man-pages man-db
```
Download a package source:
```
dnf download --source <packagename>
```

### apt
_Debian / Ubuntu family._

Requires a `deb-src` entry in the apt sources. Download a package source:
```
apt source <packagename>
```


## System administration

### System resources stress
Stress the system memory, filling up-to 90% of the RAM. The ```0.9``` value can be tweaked to fill diferent percentajes of the RAM memory.
```
stress-ng --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1
```
Stress the disks:
```
stress-ng --hdd 4 --timeout 60m /efs/
```


## Binary inspection & tracing

Static analysis reads the ELF binary without running it, so it shows what the program could call. Dynamic tracing runs the program and watches it. The distinction that matters is syscalls (kernel transitions) versus library calls (into shared `.so` files).

Three tools answer the same static questions in different ways. Libraries are the containers, imported symbols are the calls a binary makes into them, exported symbols are what a library provides.
```
# Libraries (the containers):
readelf -d /bin/ls | grep NEEDED

# Functions imported from those libraries (the actual calls), pick one:
nm -Du /bin/ls                          # cleanest
readelf --dyn-syms /bin/ls | grep UND   # readelf equivalent
objdump -T /bin/ls | grep UND           # objdump equivalent

# Exported functions (for a library, what it PROVIDES), drop the -u/UND filter:
nm -D /lib/x86_64-linux-gnu/libc.so.6 | grep ' T '   # T = defined text (function)
```

### readelf - ELF structure
Reads ELF structure like sections, headers, the dynamic table, and symbols. Shows linked libraries and imported symbols, not syscalls.
```
readelf -d /bin/ls | grep NEEDED   # shared libraries it links against (DT_NEEDED)
readelf --dyn-syms /bin/ls         # dynamic symbols; UND entries are imported functions
readelf -a /bin/ls                 # everything
```

### nm - symbol lister
Lists symbols. `U` marks undefined symbols (imported from libraries), `T` marks defined text (functions the object provides).
```
nm -D /bin/ls                      # dynamic symbols
nm -Du /bin/ls                     # only the imported (undefined) ones
nm -D libc.so.6 | grep ' T '       # exported functions a library provides
```

### objdump - disassembler
Disassembles. Syscalls are instructions rather than symbols, so `readelf` never sees them and this is the only static way to find them. `objdump -d` only shows syscalls in the code it disassembles, so on a dynamically linked binary it misses the ones inside libc (disassemble the `.so` separately for those). Even then, mapping an instruction to a syscall number means tracing back the value loaded into `rax`. For what a program actually calls, use `strace`.
```
objdump -d /bin/ls | grep -B2 syscall   # find syscall instructions
objdump -T /bin/ls                       # dynamic symbols (like nm -D)
objdump -p /bin/ls | grep NEEDED         # needed libraries
```

### strace - trace syscalls
Traces every syscall at runtime. Use it for which syscalls a program makes and for debugging permission errors or hangs. Overhead is high, so keep it off busy production hosts.
```
strace ls                                    # every syscall, live
strace -f ls                                 # follow forked children
strace -e trace=network curl example.com     # filter to a category
strace -e trace=openat,read cat /etc/hosts   # specific syscalls
strace -c ls                                 # count syscalls + time (summary)
strace -p 1234                               # attach to a running PID
strace -T ls                                 # time spent in each syscall
strace -o out.txt ls                         # write to a file
```

### ltrace - trace library calls
Traces calls into shared libraries such as `getaddrinfo`, `malloc`, and `printf`. The userspace counterpart to strace.
```
ltrace ls                              # every library-function call
ltrace -S ls                           # library calls AND syscalls interleaved
ltrace -c ls                           # count library calls
ltrace -e getaddrinfo curl example.com # filter to specific functions
ltrace -f ls                           # follow children
```

### perf - low-overhead tracing
A production-safe alternative to strace with far lower overhead. On modern systems, eBPF tools (`bpftrace`, `execsnoop`, `opensnoop`) trace syscalls fleet-wide with the least overhead.
```
perf trace ls                            # like strace, lower overhead
perf trace -p 1234                       # attach to a running PID
perf stat -e 'syscalls:sys_enter_*' ls   # count syscalls via tracepoints
```

Which tool answers which question:

| Question | Tool |
|---|---|
| Which shared libraries does it link? | `readelf -d`, `ldd`, `objdump -p` |
| Which library functions does it import? | `readelf --dyn-syms`, `nm -D -u` |
| Find syscalls without running it | `objdump -d \| grep syscall` (slow) |
| Which syscalls at runtime? | `strace` (or `perf trace` in prod) |
| Which library calls? | `ltrace` |
| Both, interleaved | `ltrace -S` |
| Syscall counts and timing | `strace -c`, `perf stat` |
| Low-overhead / production | `perf trace`, `bpftrace`, bcc tools |


## Files & text processing

### rsync
Check the command reference [here](https://linux.die.net/man/1/rsync).
```
rsync -avhzP --delete /src/ /dst/
```
Individual flags:
```
• -a (archive mode): This is actually a combination of several flags:
  • Recursive copying (-r)
  • Preserves symbolic links (-l)
  • Preserves permissions (-p)
  • Preserves timestamps (-t)
  • Preserves group (-g)
  • Preserves owner (-o)
  • Preserves device files and special files (-D)

• -v (verbose): Shows the names of files being transferred and provides additional information about what rsync is doing

• -h (human-readable): Displays file sizes in human-readable format (KB, MB, GB) instead of raw bytes

• -z (compress): Compresses data during transfer (useful for network transfers)

• -P: This is actually a combination of two flags:
  • --partial: Keeps partially transferred files (useful if transfer is interrupted)
  • --progress: Shows progress during transfer with a progress bar for each file
  
• --delete: Removes files from the destination directory that no longer exist in the source directory
```
Some samples for remote encrypted remote sync, over SSH:

Push to remote server:
```
rsync -avhzP --delete /src/ user@remote-host:/dst/
```

Pull from remote server:
```
rsync -avhzP --delete user@remote-host:/src/ /dst/
```
Sample with special options:
```
rsync -avhzP --delete -e "ssh -i ~/.ssh/my-key" /src/ user@remote-host:/dst/
```

### [grep](https://linux.die.net/man/1/grep) simple text matching

The ```grep``` command is a very powerful tool that can help us to find matching patterns, keywords or even phrases across a large number of files. While using the flags ```-r``` for recursion and ```-n``` for printing line numbers, we can easily find occurrences of a given string across an entire directory. Much more complex searches can be done with regular expressions.
```
grep -nR "keyword" ./*
```

### Get the last field with awk
```
TASK_ID=$(echo $TASK_DETAILS | jq -r '.TaskARN' | awk -F '/' '{print $NF}')
```


## Scripting

### Bash script - Validate that is not already running
Many times, specially with cron-jpbs that run very often, it is important to validate that there is only one instance of the script running at any given time. Some scripts performing atomic operations or synchronisation tasks may collision if there are two instances of the same script running at the same time. A very basic sample can be synchronising files from S3 buckets. You may want to have frequent syncs (a cron-job running every 5 minutes), but if there is a synchronisation job already taking place, you don’t want them to overlap.
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

### Bash script - Sanity checks

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

## Do stuff...
```

### Load settings from a file with awk

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

### Makefiles
Adding some somple makefiles that can be used for building your projects.
 - [Basic Makefile for Docker and AWS](./makefiles/Makefile-docker)
