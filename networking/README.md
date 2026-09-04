# Networking Fundamentals

No instructor-provided `devops-hero` repository URL existed in the supplied project. Rather than invent a link, this section provides a standard Linux networking lab that covers the assignment's tools and concepts. Add the instructor's exact URL here only if it is supplied later.

## Core concepts

- **Interface:** A host attachment point to a network, such as Ethernet `eth0`, Wi-Fi, loopback `lo`, or a virtual container interface.
- **IP address:** A Layer 3 identifier assigned to an interface. IPv4 and IPv6 addresses have an associated prefix length.
- **Subnet:** A contiguous IP range described by an address and prefix, such as `192.0.2.0/24`; hosts use it to decide what is directly reachable.
- **Default gateway:** The next-hop router selected when no more-specific route matches a destination.
- **DNS:** The distributed naming system that maps names such as `example.com` to records including IP addresses.
- **Port:** A 16-bit TCP or UDP endpoint number used to direct traffic to a process/service on a host.
- **TCP:** Connection-oriented transport with ordered, reliable byte delivery.
- **UDP:** Connectionless datagram transport with lower overhead and no built-in delivery guarantee.
- **Listening socket:** A local IP/protocol/port combination on which a process is waiting for traffic.
- **Routing:** Selecting the next hop and outgoing interface for an IP packet using the routing table.
- **Neighbor/ARP table:** A cache that maps directly reachable IP addresses to link-layer addresses. IPv4 commonly uses ARP; IPv6 uses Neighbor Discovery.

Read the [command guide](networking-commands.md), then run:

```bash
chmod +x collect-network-info.sh
./collect-network-info.sh
```

The collector checks command availability and continues when optional utilities are missing. Local interface names, addresses, routes, DNS configuration, and listening ports vary by machine. Review output before publishing it because infrastructure details can be sensitive.

By default the script performs local inspection only. Opt into benign public reachability/DNS tests with:

```bash
NETWORK_EXTERNAL=1 ./collect-network-info.sh
```

On macOS, `ifconfig`, `netstat`, and `route` are used as fallbacks because Linux `ip`, `ss`, and `hostname -I` are normally unavailable.
