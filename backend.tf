terraform {
  backend "s3" {
    bucket         = "bucket-kubernetes-labs-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "sa-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}