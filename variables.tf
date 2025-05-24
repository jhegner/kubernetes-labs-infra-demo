variable "bucket_name" {
  default = "bucket-kubernetes-labs-terraform-state"
}

variable "bucket_prefix" {
  default = "infra"
}

variable "iam_user_name" {
  default = "kubernetes-labs-terraform-user"
}

variable "region" {
  default = "sa-east-1"
}