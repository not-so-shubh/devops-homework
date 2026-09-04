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

## Objective and task coverage

The script satisfies the homework's system-information requirements: current date, hostname, username, disk usage, running processes, variables, `read -p`, `mkdir -p`, `touch`, and `ps aux >` redirection. It rejects path-like input and keeps automated output in a caller-supplied temporary base when requested.

## Actual verification and evidence

The final piped-input run is [shell-script-output.txt](../evidence/command-outputs/shell-script-output.txt). It contains the real date/host/user, `df -h` output, a PID/command process summary, the generated report path, and the success line. The terminal-only slot is described in the [screenshot checklist](../evidence/screenshots/README.md#02--shell-script); no PNG is claimed because native terminal capture was unavailable.

## Relevant files and learning summary

- [`system-info.sh`](system-info.sh) — executable Bash implementation with safe quoting and validation
- [`../evidence/command-outputs/shell-script-output.txt`](../evidence/command-outputs/shell-script-output.txt) — genuine captured output

The main lesson is to separate data collection from presentation, quote every path-bearing variable, and use redirection deliberately so a full process snapshot is retained while a safer summary is printed.
