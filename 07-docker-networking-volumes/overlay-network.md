# Docker Overlay Networks

A bridge network is local to one Docker daemon. Containers attached to bridge networks on independent hosts cannot communicate as if they share one Layer 2 segment because each daemon owns a separate local bridge and address space.

An **overlay network** creates a logical network spanning multiple Docker daemons, commonly coordinated by Docker Swarm. At a high level, hosts encapsulate container traffic across an underlay network using VXLAN. Swarm distributes network/service state and supplies service discovery so tasks can reach services by name instead of fixed container IP addresses.

## Prerequisites

- Docker Engine on each host
- Routable host-to-host connectivity
- Swarm control traffic: TCP `2377`
- Node communication: TCP/UDP `7946`
- Overlay data plane: UDP `4789`
- Appropriate firewall policy and synchronized clocks

Initialize the first manager only on a machine intentionally designated for the lab:

```bash
docker swarm init --advertise-addr <MANAGER_IP>
docker swarm join-token worker
```

Run the printed `docker swarm join --token ... <MANAGER_IP>:2377` command on each intended worker. A join token grants cluster membership and should not be posted in screenshots or committed.

Create and inspect a user-defined attachable overlay on a manager:

```bash
docker network create \
  --driver overlay \
  --attachable \
  demo-overlay

docker network ls
docker network inspect demo-overlay
```

`--attachable` lets explicitly launched standalone containers attach in addition to Swarm services. Typical use cases include cross-host application tiers, replicated services, and service-to-service communication in a Swarm stack.

## Ingress versus user-defined overlay

- Swarm's special `ingress` overlay supports the routing mesh for published service ports.
- A user-defined overlay such as `demo-overlay` carries application traffic among attached services/containers and gives explicit isolation boundaries.

Overlay control-plane traffic is protected, but application data-plane encryption is not automatically enabled for every custom network. Request IPsec encryption when required:

```bash
docker network create --driver overlay --opt encrypted secure-overlay
```

Encryption adds CPU overhead and should be benchmarked. Also use application-layer TLS and normal secrets management where appropriate.

## Safe teardown

Remove services/containers using the overlay, then:

```bash
docker network rm demo-overlay
docker swarm leave                 # worker
docker swarm leave --force         # final manager, only when intentionally dismantling lab
```

This repository does **not** initialize or leave Swarm automatically because doing so changes host-wide Docker state.
