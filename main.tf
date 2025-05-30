terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vultr = {
      source = "vultr/vultr"
      version = "2.26.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "vultr" {
  api_key = var.VULTR_API_KEY
}

# Create a Vultr instance
resource "vultr_instance" "kubernetes-vultr-instance-demo" {
    plan = var.vultr_instance_plan
    region = var.vultr_instance_region
    os_id = var.vultr_instance_os_id
    count = var.vultr_instance_count
    label = var.vultr_instance_name
    backups = var.vultr_instance_backups
}