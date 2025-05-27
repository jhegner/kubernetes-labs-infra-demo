terraform {
  backend "s3" {
    bucket         = var.bucket_name
    key            = var.key
    region         = var.region
    dynamodb_table = var.dynamodb_table
    use_lockfile   = var.use_lockfile
    profile        = var.aws_profile
  }
}