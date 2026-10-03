# Final Project Infrastructure

Terraform always creates the VPC, two public subnets, routing, private versioned artifact bucket and immutable/scanned ECR repository. Setting `enable_eks=true` additionally creates a billable EKS control plane and managed node group.

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
# Review costs and account before applying:
terraform apply tfplan
terraform output
# Remove the lab when evidence is captured:
terraform destroy
```

For the full cloud run set `enable_eks=true`, apply, then execute the `configure_kubectl` output. EKS and EC2 nodes incur hourly charges; they are disabled by default to prevent an unattended apply from spending money. State must be migrated to an encrypted remote backend with locking for team use.
