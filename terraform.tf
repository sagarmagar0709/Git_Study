resource "aws_s3_bucket" "my_bucket" {
  bucket = "sagar-demo-bucket-001"
  force_destroy = true

  tags = {
    Name = "Terraform S3 Bucket"
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "delete-old-objects"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = 0
      noncurrent_days           = 30
    }
  }
}
