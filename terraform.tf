provider "aws" {
  region = "us-east-1"
}

# Create KMS key
resource "aws_kms_key" "s3_kms" {
  description = "KMS key for S3 encryption"
}

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "sagar-demo-bucket-001"  # Change to a globally unique name

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "delete-old-objects"
    enabled = true

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_kms.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name = "Terraform S3 Bucket"
  }
}

# Optional: Bucket policy to make public (remove if private is needed)
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}
