output "bucket_name" {
  description = "Globally unique S3 bucket name."
  value       = aws_s3_bucket.homework.id
}

output "bucket_arn" {
  value = aws_s3_bucket.homework.arn
}

output "regional_domain_name" {
  value = aws_s3_bucket.homework.bucket_regional_domain_name
}
