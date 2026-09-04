# Docker Networking and Volumes

This section contains four independent exercises:

1. [Three containers across three bridge networks](container-networking/)
2. [Apache using host networking](host-network/)
3. [Read-only Nginx bind mount with live host edits](bind-mount/)
4. [Multi-host overlay network concepts and Swarm commands](overlay-network.md)

The container-networking and bind-mount labs use distinctive project/container names and include scoped cleanup. The overlay lab is documentation-only because automatically changing a developer machine's Swarm state would be intrusive. Host mode is also manual because it may collide with an existing service on port 80.
