# EC2 - Compute

Amazon EC2 provides resizable virtual machines.

- An **AMI** supplies the root filesystem and launch metadata.
- **Instance types** select CPU, memory, networking and accelerator characteristics.
- **Key pairs** support SSH public-key authentication; Session Manager can avoid exposed SSH entirely.
- **Security Groups** are stateful instance/ENI firewalls; permit only required sources and ports.
- **EBS** provides persistent block volumes with snapshot support and encryption.
- A **private IP** is used inside the VPC; a **public IPv4/Elastic IP** enables Internet routing when routing and policy also permit it.
- Lifecycle states include pending, running, stopping/stopped, shutting-down and terminated.

Common uses include web servers, build runners, batch workers and legacy applications. Production designs use launch templates, Auto Scaling, multiple Availability Zones, IAM roles, encrypted EBS, Systems Manager, monitoring and automated patching.
