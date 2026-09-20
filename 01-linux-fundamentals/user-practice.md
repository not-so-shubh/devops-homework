# `adduser` versus `useradd`

Both commands can create accounts, but their interfaces and defaults are not identical across distributions.

| Topic | `useradd` | `adduser` on Debian/Ubuntu |
|---|---|---|
| Level | Lower-level account creation utility | Friendlier Perl wrapper around lower-level tools |
| Interaction | Commonly non-interactive; options select desired properties | Traditionally interactive: prompts for password and profile fields |
| Home/shell defaults | Depend on flags and `/etc/default/useradd` / `/etc/login.defs` | Convenient Debian/Ubuntu policy defaults |
| Portability | Widely present, but defaults still vary | Name and behavior vary; it is not universally the preferred tool on every distribution |

On Ubuntu, `adduser` is commonly preferred for an administrator creating a person interactively because it conveniently creates the home directory, initializes it, prompts for a password, and applies Ubuntu's normal defaults. Automation often uses `useradd` with explicit flags because interactive prompts are undesirable.

## Ubuntu interactive practice

These commands change real host accounts and require root privileges. Review them before running, and use a clearly disposable lab machine or VM.

```bash
sudo adduser devopstest
id devopstest
getent passwd devopstest
sudo deluser --remove-home devopstest
```

An approximately equivalent explicit `useradd` creation command is:

```bash
sudo useradd -m -s /bin/bash devopstest
sudo passwd devopstest
```

Here `-m` creates a home directory and `-s /bin/bash` selects the login shell. `useradd` behavior can still be influenced by distribution configuration.

## Isolated Docker practice

This avoids modifying host users. The container is discarded on exit:

```bash
docker run --rm -it ubuntu:24.04 bash
apt-get update && apt-get install -y adduser
adduser --disabled-password --gecos '' devopstest
id devopstest
getent passwd devopstest
deluser --remove-home devopstest
exit
```

The repository's automated verifier deliberately does not create or delete real host accounts.
