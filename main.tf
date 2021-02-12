locals {
  name = "rtlab-${var.region}"
}

locals {
  ssh_keys = [data.ibm_is_ssh_key.regional_tycho_key.id, data.ibm_is_ssh_key.hyperion_regional_key.id, data.ibm_is_ssh_key.malachor_regional_key.id, data.ibm_is_ssh_key.mercury_regional_key.id]
}

module vpc {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${local.name}-vpc"
  resource_group = data.ibm_resource_group.cde.id
  tags           = concat(var.tags, ["region:${var.region}", "vpc:${local.name}-vpc", "provider:ibmcloud"])
}


module frontend_gateway {
  count             = length(data.ibm_is_zones.mzr.zones)
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name              = "${local.name}-${element(data.ibm_is_zones.mzr.zones[*], count.index)}-pgw"
  zone              = element(data.ibm_is_zones.mzr.zones[*], count.index)
  vpc_id            = module.vpc.id
  resource_group_id = data.ibm_resource_group.cde.id
  tags              = concat(var.tags, ["zone:${element(data.ibm_is_zones.mzr.zones[*], count.index)}", "region:${var.region}", "vpc:${local.name}-vpc", "provider:ibmcloud"])
}

module frontend_subnet {
  count          = length(data.ibm_is_zones.mzr.zones)
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = "${local.name}-${element(data.ibm_is_zones.mzr.zones[*], count.index)}-frontend-subnet"
  resource_group = data.ibm_resource_group.cde.id
  network_acl    = module.vpc.default_network_acl
  address_count  = "32"
  vpc            = module.vpc.id
  zone           = element(data.ibm_is_zones.mzr.zones[*], count.index)
  public_gateway = element(module.frontend_gateway[*].id, count.index)
}

module services_subnet {
  count          = length(data.ibm_is_zones.mzr.zones)
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = "${local.name}-${element(data.ibm_is_zones.mzr.zones[*], count.index)}-services-subnet"
  resource_group = data.ibm_resource_group.cde.id
  network_acl    = module.vpc.default_network_acl
  address_count  = "128"
  vpc            = module.vpc.id
  zone           = element(data.ibm_is_zones.mzr.zones[*], count.index)
  public_gateway = element(module.frontend_gateway[*].id, count.index)
}

module security {
  source           = "./security"
  name             = local.name
  resource_group   = data.ibm_resource_group.cde.id
  vpc_id           = module.vpc.id
  remote_addresses = var.remote_addresses
  frontend_subnet  = module.frontend_subnet[*].ipv4_cidr_block
  services_subnet  = module.services_subnet[*].ipv4_cidr_block
}

module bastion {
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = module.vpc.id
  subnet_id         = module.frontend_subnet[0].id
  ssh_keys          = local.ssh_keys
  resource_group    = data.ibm_resource_group.cde.id
  name              = "${local.name}-bastion"
  zone              = data.ibm_is_zones.mzr.zones[0]
  security_group_id = module.security.maintenance_sg_id
  tags              = concat(var.tags, ["zone:${data.ibm_is_zones.mzr.zones[0]}", "region:${var.region}", "vpc:${local.name}-vpc", "provider:ibmcloud"])
  user_data         = file("${path.module}/install.yml")
}

module consul {
  count             = length(data.ibm_is_zones.mzr.zones)
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = module.vpc.id
  subnet_id         = element(module.services_subnet[*].id, count.index)
  ssh_keys          = local.ssh_keys
  resource_group    = data.ibm_resource_group.cde.id
  name              = "${local.name}-consul${count.index + 1}"
  zone              = element(data.ibm_is_zones.mzr.zones[*], count.index)
  security_group_id = module.security.services_sg_id
  tags              = concat(var.tags, ["zone:${data.ibm_is_zones.mzr.zones[0]}", "region:${var.region}", "vpc:${local.name}-vpc", "provider:ibmcloud"])
  user_data         = file("${path.module}/install.yml")
}

resource ibm_is_floating_ip bastion {
  name   = "${local.name}-bastion-address"
  target = module.bastion.primary_network_interface_id
}

module ansible {
  source               = "./ansible"
  instances            = module.consul[*].instance
  bastion              = ibm_is_floating_ip.bastion.address
  client_private_key   = var.client_private_key
  client_public_key    = var.client_public_key
  client_preshared_key = var.client_preshared_key
  encrypt_key          = var.encrypt_key
  region               = var.region
  logdna_ingestion_key = var.logdna_ingestion_key
  sysdig_key           = var.sysdig_key
  acl_token            = var.acl_token
  cse_addresses        = join(", ", flatten(module.vpc.cse_source_addresses[*].address))
  subnets              = join(", ", [format("%s0.0/18", substr(module.frontend_subnet[0].ipv4_cidr_block, 0, 7)), format("%s.0/18", substr(module.frontend_subnet[1].ipv4_cidr_block, 0, 9)), format("%s.0/18", substr(module.frontend_subnet[2].ipv4_cidr_block, 0, 10))])
}
