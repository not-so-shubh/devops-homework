resource "random_id" "bucket" {
  byte_length = 4
}

locals {
  bucket_name = "${var.bucket_prefix}-${random_id.bucket.hex}"
}

resource "aws_s3_bucket" "homework" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_ownership_controls" "homework" {
  bucket = aws_s3_bucket.homework.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "homework" {
  bucket                  = aws_s3_bucket.homework.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "homework" {
  bucket = aws_s3_bucket.homework.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "homework" {
  bucket = aws_s3_bucket.homework.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "homework" {
  bucket     = aws_s3_bucket.homework.id
  depends_on = [aws_s3_bucket_versioning.homework]

  rule {
    id     = "expire-noncurrent-lab-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
