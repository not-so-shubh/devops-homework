# IAM - Governance

AWS Identity and Access Management controls authentication and authorization for AWS APIs.

- **Users** represent long-lived human or application identities, though workforce federation and roles are preferred.
- **Groups** attach common policies to collections of IAM users.
- **Roles** provide temporary credentials to trusted principals such as EC2, GitHub Actions through OIDC, or another AWS account.
- **Policies** are JSON documents containing Effect, Action, Resource and optional Condition statements.
- **Permissions** are the effective result of identity policies, resource policies, permissions boundaries, SCPs and explicit denies.
- **Least privilege** grants only required actions on required resources, then reduces permissions using access evidence.

Best practices: enable MFA, use federation/SSO for people, use temporary role credentials for workloads, rotate or remove unused keys, protect the root user, review CloudTrail, apply conditions, use permission boundaries for delegation and run IAM Access Analyzer. Common uses include granting an EC2 role S3 read access, allowing CI to assume a deployment role through OIDC and separating administrator, developer and auditor duties.
