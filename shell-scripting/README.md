# System Information Shell Script

`system-info.sh` demonstrates the exact Bash concepts required by the assignment: variables, `read -p`, `mkdir -p`, `touch`, `echo`, `df`, `ps`, safe quoting, and `>` output redirection.

## Run it

```bash
chmod +x system-info.sh
./system-info.sh
```

At the prompt, enter a directory **name**, not a path. A blank answer uses `system-info-output`. The directory is created below this folder. Names containing `/`, `.` or `..` are rejected so the script cannot unexpectedly write somewhere else.

Non-interactive test:

```bash
printf 'my-report\n' | ./system-info.sh
```

## How it works

1. The Bash shebang selects Bash and `set -u` rejects accidental use of unset variables.
2. `SCRIPT_DIR`, `CURRENT_DATE`, `HOST_NAME`, and `CURRENT_USER` store reusable values.
3. `read -r -p` reads a directory name without interpreting backslashes; a blank answer selects a default.
4. `mkdir -p "$OUTPUT_DIR"` safely creates the requested directory below the controlled base directory.
5. `touch "$PROCESS_FILE"` explicitly creates the process report.
6. `ps aux > "$PROCESS_FILE"` writes the complete process snapshot, replacing any prior report.
7. The terminal displays date, hostname, current user, `df -h`, a process summary using PID and command name, and the saved report path.

The optional `SYSTEM_INFO_BASE_DIR` environment variable lets automated tests redirect output to a temporary directory without leaving generated artifacts in the repository:

```bash
tmp_dir="$(mktemp -d)"
printf 'automated report\n' | SYSTEM_INFO_BASE_DIR="$tmp_dir" ./system-info.sh
```

## Expected output shape

```text
=== System Information ===
Current date : <date and time>
Hostname     : <machine hostname>
Current user : <effective username>

=== Disk Usage ===
<df -h output>

=== Running Process Summary (PID and command) ===
<first process entries>

Full process list saved to: <chosen directory>/running-processes.txt
PASS: system information collected successfully.
```

Values differ by machine and execution time. A real run from this environment is stored under `evidence/command-outputs/`.
