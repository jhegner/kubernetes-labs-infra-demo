variable "bucket_name" {
  default = "bucket-kubernetes-labs-terraform-state"
}

variable "region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "kubernetes-labs"  
}

variable "key" {
  default = "lab/state"   
}

variable "dynamodb_table" {
  default = "table-kubernetes-labs-terraform-backend-state"
}

variable "use_lockfile" {
  default = true  
}