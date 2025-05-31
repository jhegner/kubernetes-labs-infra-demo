terraform {
  backend "s3" {
    bucket         = "kubernetes-labs-tf-backend-aws-s3bucket"
    key            = "lab/state/terraform"
    region         = "us-east-1"
    use_lockfile   = true
  }
}