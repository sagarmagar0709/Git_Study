terraform {
  backend "s3" {
    bucket         = "sagar-demo-bucket-0012"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
