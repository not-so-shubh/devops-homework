provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "devops-homework-s3"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Student     = "24BCS10601"
    }
  }
}
