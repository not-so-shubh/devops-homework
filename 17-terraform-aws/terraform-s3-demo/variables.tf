variable "aws_region" {
  description = "AWS region for the S3 API and supporting resources."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_prefix" {
  description = "Lowercase prefix; a random suffix makes the bucket globally unique."
  type        = string
  default     = "shubh-devops-homework"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,40}$", var.bucket_prefix))
    error_message = "bucket_prefix must be 3-41 lowercase letters, numbers or hyphens."
  }
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "force_destroy" {
  description = "Permit Terraform to delete a non-empty lab bucket. Keep false unless deliberate."
  type        = bool
  default     = false
}
