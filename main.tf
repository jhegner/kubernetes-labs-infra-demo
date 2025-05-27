terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-kubernetes-labs-terraform-backend"
    key            = "lab/state"
    region         = "us-east-1"
    dynamodb_table = "table-kubernetes-labs-terraform-backend-state"
    use_lockfile   = true
  }

}

provider "aws" {
  region = "us-east-1"
}