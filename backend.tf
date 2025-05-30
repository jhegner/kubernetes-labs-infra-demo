terraform {
  backend "s3" {
    bucket         = "bucket-kubernetes-labs-terraform-backend"
    key            = "bucket-kubernetes-labs-terraform-backend/lab/state/key.tflock"
    region         = "us-east-1"
    use_lockfile   = true
  }
}