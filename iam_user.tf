provider "aws" {
  region = "us-east-1"
}

# 1. Create IAM User
resource "aws_iam_user" "terraform_user" {
  name = "terraform-state-user"
}

# 2. Create IAM Policy for S3 & DynamoDB access
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccessPolicy"
  description = "Access to private S3 bucket and DynamoDB for state management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowReadWriteTerraformState",
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::sagar-demo-bucket-0012",
          "arn:aws:s3:::sagar-demo-bucket-0012/terraform.tfstate"
        ]
      },
      {
        Sid    = "AllowDynamoDBStateLocking",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:364337333456:table/terraform-locks"
      }
    ]
  })
}

# 3. Attach Policy to IAM User
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}
