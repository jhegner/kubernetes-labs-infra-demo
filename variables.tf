
# This variable is used to specify the Vultr API key, which is stored in GitHub Secrets.
variable "VULTR_API_KEY" {}


variable "vultr_instance_name" {
  description = "Name of the Vultr instance"
  default = "instance-kubernetes-vultr-demo"
  type    = string  
}

variable "vultr_instance_count" {
  description = "Number of Vultr instances to create"
  default = 1
  type    = number
}

variable "vultr_instance_plan" {
  description = "Vultr instance plan"
  default = "vc2-1c-1gb"
  type    = string
}

# mia - Miami
variable "vultr_instance_region" {
  description = "Vultr instance region"
  default = "mia"
  type    = string
}

variable "vultr_instance_os_id" {
  description = "Vultr instance OS ID"
  default = 387
  type    = number
}

variable "vultr_instance_backups" {
  description = "Vultr instance backups"
  default = "disabled"
  type    = string
}