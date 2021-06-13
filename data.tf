
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_is_zones" "mzr" {
  region = var.region
}

data "ibm_is_ssh_key" "deploymentKey" {
  name = var.ssh_key
}

data "ibm_is_vpc" "existing" {
  count = var.existing_vpc != "" ? 1 : 0
  name  = var.existing_vpc
}

#
# Retrieve the VPC subnets (so it populates all fields like ipv4_cidr_block)
#
data "ibm_is_subnet" "subnet" {
  count      = var.existing_vpc != "" ? length(local.vpc.subnets) : 0
  identifier = local.vpc.subnets[count.index].id
}

data "ibm_is_subnets" "existing_subnets" {
  count = var.existing_vpc != "" ? 1 : 0
}

data "ibm_is_subnet" "existing_subnet" {
  count      = var.existing_subnet_id != "" ? 1 : 0
  identifier = var.existing_subnet_id
}

data "ibm_is_instance" "existing_bastion" {
  count = var.existing_bastion_instance != "" ? 1 : 0
  name  = var.existing_bastion_instance
}