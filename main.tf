terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.26.0"
    }
  }
}

# Configure the Vultr Provider
provider "vultr" {
  api_key = var.vultr_api_key
}

# Create a Vultr instance
resource "vultr_instance" "kubernetes-vultr-instance-demo" {
    plan = var.vultr_instance_plan
    region = var.vultr_instance_region
    os_id = var.vultr_instance_os_id
    count = var.vultr_instance_count
    label = var.vultr_instance_name
}