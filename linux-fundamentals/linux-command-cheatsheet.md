# Linux Command Cheat Sheet

Each example is intentionally small. Add `--help` or read `man <command>` before using unfamiliar destructive or privileged options.

## Navigation

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `pwd` | Print working directory | `pwd` | Shows the absolute path of the current directory. |
| `ls` | List directory entries | `ls -lah /var/log` | Long format, including hidden files and human-readable sizes. |
| `cd` | Change directory | `cd /etc` | Makes `/etc` the shell's current directory. |

## Files and directories

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `touch` | Create an empty file/update timestamps | `touch notes.txt` | Creates `notes.txt` if absent. |
| `cp` | Copy files/directories | `cp source.txt backup.txt` | Copies file contents and creates/replaces the destination. |
| `mv` | Move or rename | `mv old.txt new.txt` | Renames within a filesystem or moves to a new location. |
| `rm` | Unlink files | `rm -- old.txt` | Removes the named file; recovery is not guaranteed. |
| `mkdir` | Create directories | `mkdir -p project/logs` | Creates missing parent directories too. |
| `rmdir` | Remove empty directories | `rmdir empty-dir` | Refuses if the directory contains entries. |
| `cat` | Concatenate/display files | `cat /etc/os-release` | Writes the file to standard output. |
| `less` | Page through text | `less large.log` | Interactive viewer; press `q` to quit. |
| `head` | Show beginning | `head -n 20 app.log` | Prints the first 20 lines. |
| `tail` | Show end/follow additions | `tail -f app.log` | Prints the end and waits for new lines. |

## Search

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `find` | Search filesystem entries | `find . -type f -name '*.sh'` | Finds shell files below the current directory. |
| `grep` | Search text | `grep -Rni 'error' logs/` | Recursively reports case-insensitive matches with line numbers. |

## Permissions and ownership

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `chmod` | Change permission bits | `chmod u+x script.sh` | Adds execute permission for the owner. |
| `chown` | Change owner/group | `sudo chown alice:dev file` | Assigns user `alice` and group `dev`. |
| `chgrp` | Change group | `chgrp developers file` | Changes group ownership only. |

## Users

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `whoami` | Print effective username | `whoami` | Shows the current effective account name. |
| `id` | Show user/group IDs | `id alice` | Reports numeric IDs and group membership. |
| `who` | Show logged-in sessions | `who` | Lists current user login sessions. |
| `sudo` | Run with delegated privilege | `sudo systemctl restart nginx` | Runs one command under configured sudo policy. |

## Processes

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `ps` | Snapshot processes | `ps aux` | BSD-style listing of processes and resource use. |
| `top` | Interactive process monitor | `top` | Refreshes CPU/memory/process information. |
| `kill` | Signal a PID | `kill -TERM 1234` | Requests orderly termination; avoid `-KILL` unless necessary. |
| `pkill` | Signal by name/pattern | `pkill -TERM nginx` | Signals matching processes; inspect matches first with `pgrep`. |

## Disk and memory

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `df` | Filesystem free space | `df -h` | Reports used and available filesystem capacity. |
| `du` | Entry disk usage | `du -sh ./data` | Summarizes space used below `data`. |
| `free` | RAM/swap usage | `free -h` | Linux memory totals in human-readable units. |

## Networking

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `ip` | Configure/inspect networking | `ip addr show` | Shows interfaces and assigned addresses. |
| `ping` | Test IP reachability/latency | `ping -c 4 1.1.1.1` | Sends four ICMP echo requests where permitted. |
| `ss` | Inspect sockets | `ss -tuln` | Lists listening TCP/UDP sockets numerically. |
| `curl` | Transfer/test URLs | `curl -fsS http://localhost:8080/` | Fetches an HTTP resource and fails on HTTP errors. |
| `wget` | Download resources | `wget https://example.com/file` | Saves a remote resource to a file. |
| `dig` | Detailed DNS query | `dig example.com A` | Queries A records and prints DNS sections/timing. |
| `nslookup` | Simple DNS lookup | `nslookup example.com` | Displays resolver answers; `dig` is often better for diagnosis. |

## Archives and compression

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `tar` | Bundle/archive files | `tar -czf logs.tar.gz logs/` | Creates a gzip-compressed tar archive. |
| `gzip` | Compress one stream/file | `gzip report.txt` | Replaces it with `report.txt.gz` by default. |
| `gunzip` | Decompress gzip | `gunzip report.txt.gz` | Restores the uncompressed file. |

## System information

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `uname` | Kernel/system details | `uname -a` | Reports kernel, architecture, and related data. |
| `hostname` | Show/set host name | `hostname` | Without arguments, prints the current hostname. |
| `date` | Show/format date | `date -Iseconds` | Prints an ISO-like timestamp with timezone offset. |
| `uptime` | Runtime/load averages | `uptime` | Shows time since boot, users, and load averages. |

## Services and logs

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `systemctl` | Manage systemd units | `sudo systemctl status ssh` | Shows the SSH unit's state and recent messages. |
| `journalctl` | Query systemd journal | `sudo journalctl -u ssh -b` | Shows SSH records from the current boot. |

## Shell environment

| Command | Purpose | Basic syntax/example | Explanation |
|---|---|---|---|
| `echo` | Write arguments | `echo "$PATH"` | Prints the expanded `PATH`; quoting preserves it as one argument. |
| `history` | Show shell history | `history 20` | Displays recent interactive commands; output may contain sensitive data. |
| `which` | Find executable via `PATH` | `which bash` | Shows the command resolved by the current search path. |
| `whereis` | Find binary/source/man paths | `whereis nginx` | Searches standard locations, not arbitrary directories. |
| `env` | Show environment/run with changes | `env` | Prints exported environment variables; review before sharing. |
| `export` | Export shell variable | `export APP_ENV=development` | Makes a variable available to child processes. |
