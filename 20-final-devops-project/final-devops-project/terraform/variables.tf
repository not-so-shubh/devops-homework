variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project_name" {
  type    = string
  default = "final-devops-project"
}

variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
}
variable "enable_eks" {
  description = "EKS incurs hourly charges; enable only for the supervised cloud lab."
  type        = bool
  default     = false
}
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}
