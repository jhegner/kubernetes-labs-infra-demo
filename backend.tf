terraform {
  backend "s3" {
    bucket         = "bucket-kubernetes-labs-terraform-state"
    key            = "lab/state"
    region         = "us-east-1"
    dynamodb_table = "table-kubernetes-labs-terraform-backend-state"
  }
}