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
  count = var.existing_vpc != "" ? 1 : 0
  name  = var.existing_vpc
}

data "ibm_is_subnet" "existing_subnet" {
  count = var.existing_vpc != "" ? 1 : 0
  name  = var.existing_subnet_name
}

