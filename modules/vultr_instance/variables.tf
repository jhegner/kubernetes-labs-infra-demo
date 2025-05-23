# This file contains the variables used in the Terraform configuration for creating a Kubernetes cluster on Vultr.

# This variable is used to specify the name of the Vultr instance that will be created.
variable "vultr_instance_name" {
  description = "Name of the Vultr instance"
  default = "kubernetes-vultr-instance-demo"
  type    = string  
}

# This variable is used to specify the number of Vultr instances to create.
variable "vultr_instance_count" {
  description = "Number of Vultr instances to create"
  default = 1
  type    = number
}

# This variable is used to specify the plan, region, and OS ID for the Vultr instance.
variable "vultr_instance_plan" {
  description = "Vultr instance plan"
  default = "vc2-1c-0.5gb-free"
  type    = string
}

# This variable is used to specify the region and OS ID for the Vultr instance.
variable "vultr_instance_region" {
  description = "Vultr instance region"
  default = "mia"
  type    = string
}

# This variable is used to specify the OS ID for the Vultr instance.
variable "vultr_instance_os_id" {
  description = "Vultr instance OS ID"
  default = 387
  type    = number
}
