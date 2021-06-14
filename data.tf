data "ibm_resource_group" "group" {
  count = var.existing_resource_group != "" ? 1 : 0
  name  = var.existing_resource_group
}

data "ibm_is_zones" "mzr" {
  region = var.region
}

data "ibm_is_ssh_key" "existing_ssh_key" {
  count = var.existing_ssh_key != "" ? 1 : 0
  name  = var.existing_ssh_key
}

data "ibm_is_vpc" "existing_vpc" {
  name = var.existing_vpc_name
}

data "ibm_is_subnet" "existing_subnet" {
  name = var.existing_subnet_name
}

data "ibm_is_instance" "existing_bastion" {
  count = var.existing_bastion_instance != "" ? 1 : 0
  name  = var.existing_bastion_instance
}
