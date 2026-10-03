output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "instance_id" {
  value = aws_instance.web.id
}

output "application_url" {
  value = "http://${aws_instance.web.public_ip}/"
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.id
}
