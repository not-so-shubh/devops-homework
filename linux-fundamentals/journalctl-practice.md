# `journalctl` Practice

On a systemd-based Linux system, `systemd-journald` collects structured log records from the kernel, boot process, services, and applications. `journalctl` queries those records. Access to some records may require `sudo` or membership in groups such as `systemd-journal` or `adm`.

| Command | Purpose |
|---|---|
| `journalctl` | Show journal records, normally oldest first in a pager. |
| `journalctl -b` | Show records from the current boot. |
| `journalctl -b -1` | Show the previous boot if persistent earlier-boot data exists. |
| `journalctl -f` | Follow new records, similar to `tail -f`; stop with Ctrl+C. |
| `journalctl -p err` | Show error-priority records and more severe priorities. |
| `journalctl --since "1 hour ago"` | Limit records to the last hour. |
| `journalctl --since today` | Show records since local midnight. |
| `journalctl -u ssh` | Filter by the SSH unit (often `ssh.service` on Ubuntu). |
| `journalctl -u nginx` | Filter by the Nginx unit. |
| `journalctl -u docker` | Filter by the Docker daemon unit. |
| `journalctl -xe` | Jump near the end and add available explanatory catalog text. |
| `systemctl status <service>` | Show unit state plus a small recent log excerpt. |

Useful combinations:

```bash
sudo journalctl -u nginx --since today -p warning
sudo journalctl -k -b                 # kernel messages from this boot
sudo journalctl --disk-usage
sudo journalctl --list-boots
sudo systemctl status docker
```

`-p err` is a priority ceiling: it includes emergency, alert, critical, and error messages. Unit names vary, so find candidates with `systemctl list-units --type=service`.

Persistent previous-boot logs require persistent journal storage (commonly `/var/log/journal`) and a recorded previous boot. Minimal containers often do not run systemd even when their filesystem is Ubuntu.

macOS does not use systemd or `journalctl`; it uses Apple's unified logging system. Run this exercise on an Ubuntu host/VM with systemd. This repository does not fabricate journal output when systemd is unavailable.
