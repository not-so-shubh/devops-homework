# Session 18 - Terraform and Infrastructure as Code

**Student:** Shubh Jaiswal
**Enrollment:** 24BCS10601

This section contains the required S3 Terraform project and separate AWS service research notes.

## Structure

```text
17-terraform-aws/
├── terraform-s3-demo/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── versions.tf
│   ├── terraform.tfvars
│   └── README.md
└── aws-services/
    ├── 01-iam/README.md
    ├── 02-ec2/README.md
    ├── 03-s3/README.md
    ├── 04-vpc/README.md
    └── 05-dynamodb-rds/README.md
```

Run `terraform fmt -check -recursive` and `terraform validate` before any cloud operation. Applying creates a real S3 bucket; confirm the AWS account and region first and always run `terraform destroy` after the lab.
