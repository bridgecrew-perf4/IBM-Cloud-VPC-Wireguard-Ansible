resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "generated_key" {
  name           = "${local.name}-${var.region}-key"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["region:${var.region}", "vpc:${local.name}-vpc"])
}

locals {
  name        = var.name != "" ? var.name : "wg"
  ssh_key_ids = var.ssh_key != "" ? [data.ibm_is_ssh_key.deploymentKey.id, ibm_is_ssh_key.generated_key.id] : [ibm_is_ssh_key.generated_key.id]
  vpc         = var.existing_vpc != "" ? data.ibm_is_vpc.existing.0 : module.vpc.0.vpc
  zone        = var.zone != "" ? "${var.region}-${var.zone}" : "${var.region}-1"
  gateway     = var.existing_subnet_id != "" ? null : module.gateway.0.id
}

module "vpc" {
  count          = var.existing_vpc != "" ? 0 : 1
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${local.name}-vpc"
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["region:${var.region}", "vpc:${local.name}-vpc"])
}

module "gateway" {
  count          = var.existing_subnet_id != "" ? 0 : 1
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name           = "${local.name}-${element(data.ibm_is_zones.mzr.zones[*], count.index)}-pgw"
  zone           = local.zone
  vpc            = local.vpc.id
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["zone:${local.zone}", "region:${var.region}", "vpc:${local.name}-vpc"])
}

module "subnet" {
  count          = var.existing_subnet_id != "" ? 0 : 1
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = "${local.name}-${data.ibm_is_zones.mzr.zones[0]}-subnet"
  resource_group = data.ibm_resource_group.group.id
  address_count  = "32"
  vpc            = local.vpc.id
  zone           = local.zone
  public_gateway = local.gateway
  tags           = concat(var.tags, ["zone:${local.zone}", "region:${var.region}", "vpc:${local.name}-vpc"])
}

locals {
  subnets = var.existing_vpc != "" ? [
    for subnet in data.ibm_is_subnets.existing_subnets.0.subnets :
    subnet if subnet.vpc == data.ibm_is_vpc.existing.0.id
  ] : module.subnet
  bastion_subnet_id = var.existing_subnet_id != "" ? data.ibm_is_subnet.existing_subnet.0.id : local.subnets.0.id
}

module "wireguard" {
  source            = "we-work-in-the-cloud/vpc-bastion/ibm"
  version           = "0.0.7"
  name              = "${local.name}-wg"
  resource_group_id = data.ibm_resource_group.group.id
  vpc_id            = local.vpc.id
  subnet_id         = local.bastion_subnet_id
  ssh_key_ids       = local.ssh_key_ids
  allow_ssh_from    = var.allow_ssh_from
  create_public_ip  = var.create_public_ip
  image_name        = "ibm-ubuntu-20-04-minimal-amd64-2"
  init_script       = file("${path.module}/install.yml")
}

resource "ibm_is_security_group_rule" "wg_udp" {
  group     = module.wireguard.bastion_security_group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 51280
    port_max = 51280
  }
}

module "ansible" {
  source               = "./ansible"
  bastion              = module.wireguard.bastion_public_ip
  region               = var.region
  cse_addresses        = join(", ", flatten(local.vpc.cse_source_addresses[*].address))
  subnets              = local.subnets
  client_private_key   = var.client_private_key
  client_public_key    = var.client_public_key
  client_preshared_key = var.client_preshared_key
}
