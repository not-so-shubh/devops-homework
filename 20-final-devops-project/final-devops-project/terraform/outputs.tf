output "vpc_id" { value = aws_vpc.main.id }
output "subnet_ids" { value = aws_subnet.public[*].id }
output "ecr_repository_url" { value = aws_ecr_repository.app.repository_url }
output "artifact_bucket" { value = aws_s3_bucket.artifacts.id }
output "eks_cluster_name" { value = try(aws_eks_cluster.main[0].name, null) }
output "configure_kubectl" {
  value = var.enable_eks ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.project_name}" : "Set enable_eks=true only during the supervised paid lab."
}
