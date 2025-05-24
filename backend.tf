terraform {
  backend "s3" {
    bucket       = "bucket-kubernetes-labs-terraform-state"
    key          = "terraform.tfstate"
    region       = "sa-east-1"
    use_lockfile = true
    encrypt      = true
  }
}