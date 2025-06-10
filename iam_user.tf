resource "aws_iam_user" "terraform_user" {
  name = "terraform-user"
}

resource "aws_iam_user_policy" "terraform_state_access" {
  name = "TerraformStateAccess"
  user = aws_iam_user.terraform_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::sagar-demo-bucket-0012",
          "arn:aws:s3:::sagar-demo-bucket-0012/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/terraform-locks"
      }
    ]
  })
}

resource "aws_iam_access_key" "terraform_user_key" {
  user = aws_iam_user.terraform_user.name
}

data "aws_caller_identity" "current" {}

output "terraform_access_key_id" {
  value     = aws_iam_access_key.terraform_user_key.id
  sensitive = true
}

output "terraform_secret_access_key" {
  value     = aws_iam_access_key.terraform_user_key.secret
  sensitive = true
}
