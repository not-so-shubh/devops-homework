# Networking Commands

## Host and interfaces

| Command | What it does | Interpretation |
|---|---|---|
| `hostname` | Prints the system hostname. | A host label, not necessarily a DNS-resolvable fully qualified name. |
| `hostname -I` | Prints assigned non-loopback addresses on Linux. | Output can contain several IPv4/IPv6 addresses. |
| `ip addr` | Shows interfaces, state, MAC, addresses, and prefixes. | `127.0.0.1/8` and `::1/128` belong to loopback. |
| `ip link` | Shows link-layer interfaces and state. | Look for `UP`, MTU, and link/MAC address. |

## Routes and neighbors

| Command | What it does | Interpretation |
|---|---|---|
| `ip route` | Shows the IPv4 routing table. | `default via ... dev ...` identifies the default gateway/interface. |
| `ip neigh` | Shows the kernel neighbor table. | Maps on-link IP addresses to MAC addresses and reachability states. |
| `arp -an` | Shows the legacy IPv4 ARP cache if installed. | Superseded by `ip neigh` on modern Linux. |
| `traceroute example.com` | Probes successive Layer 3 hops. | Firewalls/load balancing can hide or vary hops. |
| `tracepath example.com` | Traces a path without the same privilege needs as some traceroute modes. | Often also reports path MTU observations. |

## Reachability and HTTP

| Command | What it does | Interpretation |
|---|---|---|
| `ping -c 4 1.1.1.1` | Sends four ICMP echo requests. | Failure does not prove the target is down; ICMP may be blocked. |
| `curl -I https://example.com` | Fetches HTTP response headers. | Confirms DNS, TCP/TLS, and application response when successful. |
| `wget --spider https://example.com` | Checks a URL without saving its body. | Exit status reports whether retrieval succeeded. |

## Sockets and ports

| Command | What it does | Interpretation |
|---|---|---|
| `ss -tulnp` | Shows TCP/UDP listening sockets, numeric ports, and permitted process data. | `0.0.0.0:80` listens on all IPv4 interfaces; `127.0.0.1:80` is local-only. |
| `netstat -tulnp` | Legacy alternative when installed. | Modern Linux generally prefers `ss`. Root may be needed for process names. |

Options: `-t` TCP, `-u` UDP, `-l` listening, `-n` numeric, and `-p` process. Exposing a container port maps a host listening socket to a container port; it does not change the service's internal port.

## DNS

| Command | What it does | Interpretation |
|---|---|---|
| `nslookup example.com` | Performs a straightforward DNS query. | Displays the answering resolver and returned addresses. |
| `dig example.com A` | Queries IPv4 address records with detailed DNS metadata. | Inspect status, answer, flags, TTL, and server. |
| `dig example.com AAAA` | Queries IPv6 address records. | An empty answer can be valid if no AAAA record exists. |

`/etc/resolv.conf` lists resolver configuration such as `nameserver` and search domains. On systemd-resolved systems it may point at a local stub resolver, so use `resolvectl status` for full per-link settings.

## Local name overrides

`/etc/hosts` maps names locally before or alongside DNS according to `/etc/nsswitch.conf`. A common entry is:

```text
127.0.0.1 localhost
```

Editing it usually requires root privileges. Do not add arbitrary production names during practice.

## Safe practice sequence

```bash
hostname
hostname -I
ip addr
ip link
ip route
ip neigh
ss -tulnp
cat /etc/hosts
cat /etc/resolv.conf
dig example.com A
ping -c 4 1.1.1.1
curl -I https://example.com
```

Use `sudo` only when needed; avoid publishing unreviewed local addresses, internal domain suffixes, or process command lines.
