# This file contains the resources for the Vultr Kubernetes cluster demo.

resource "vultr_instance" "kubernetes-vultr-instance-demo" {
    plan = var.vultr_instance_plan
    region = var.vultr_instance_region
    os_id = var.vultr_instance_os_id
    count = var.vultr_instance_count
    label = var.vultr_instance_name
}