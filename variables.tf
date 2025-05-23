# This file contains the variables used in the Terraform configuration for creating a Kubernetes cluster on Vultr.
variable "vultr_api_key" {
  description = "Vultr API Key stored in Gitub Secrets"
  type        = string
  sensitive   = true
}

