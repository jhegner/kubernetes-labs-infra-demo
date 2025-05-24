terraform {
  backend "s3" {
    bucket       = "bucket-kubernetes-labs-terraform-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}