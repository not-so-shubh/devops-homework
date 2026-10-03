# VPC - Networking

A Virtual Private Cloud is a logically isolated IP network in one AWS Region.

- **CIDR** defines the address range, such as `10.20.0.0/16`.
- **Subnets** are Availability-Zone-scoped CIDR slices.
- **Route tables** select next hops for destination prefixes.
- An **Internet Gateway** provides a route between public IPv4/IPv6 addresses and the Internet.
- A **NAT Gateway** lets private-subnet IPv4 workloads initiate Internet connections without accepting unsolicited inbound connections.
- **Security Groups** are stateful ENI-level controls.
- **Network ACLs** are stateless subnet-level allow/deny rules.
- A **public subnet** has a route to an Internet Gateway; a **private subnet** does not. A public route alone does not make an instance public without a public address and permissive security controls.

Production networks use multiple Availability Zones, small and reviewable CIDRs, VPC endpoints for AWS services, flow logs, constrained egress and separate routing/security boundaries.
