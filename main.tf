terraform {
  backend "s3" {
    bucket = "bucket-kubernetes-labs-terraform-state"
    key = "infra/terraform.tfstate" 
    region = "us-east-1"
    use_lockfile = "terraform-lock"
    encrypt = true
  }
}