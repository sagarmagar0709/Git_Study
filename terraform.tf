provider "aws" {
  region = "us-east-1"
}

# KMS Key for S3 encryption
resource "aws_kms_key" "s3_kms" {
  description = "KMS key for S3 encryption"
}

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "sagar-demo-bucket-001"  # Must be globally unique
  force_destroy = true

  tags = {
    Name = "Terraform S3 Bucket"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption using KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_sse" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Apply lifecycle rule to delete objects after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "delete-old-objects"
    status = "Enabled"

    filter {
      prefix = ""  # Apply to all objects
    }

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Optional: Public read bucket policy
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}
