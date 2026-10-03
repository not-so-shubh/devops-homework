# S3 - Storage

Amazon S3 is regional object storage. A globally unique **bucket** contains **objects** addressed by keys; it is not a POSIX filesystem.

- Storage classes balance access latency, availability and cost: Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant Retrieval, Flexible Retrieval and Deep Archive.
- **Versioning** retains multiple object versions and protects against accidental overwrite/delete.
- **Lifecycle policies** transition or expire objects/versions automatically.
- **Encryption** can use SSE-S3, SSE-KMS, DSSE-KMS or client-side encryption.
- **Bucket policies** are resource policies; combine them with IAM and Block Public Access.

Best practices: enable Block Public Access, least privilege, versioning, encryption, access logging/CloudTrail data events where needed, lifecycle management and explicit ownership controls. Use cases include backups, artifacts, data lakes, static assets and Terraform remote state.
