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
  # bastion         = var.existing_bastion_instance != "" ? data.ibm_is_instance.existing_bastion.0. : module.bastion.bastion_public_ip
  zone    = var.zone != "" ? "${var.region}-${var.zone}" : "${var.region}-1"
  gateway = var.existing_subnet_id != "" ? null : module.gateway.0.id
}

module "vpc" {
  count          = var.existing_vpc_name != "" ? 0 : 1
  source         = "./vpc"
  name           = "${var.name}-vpc"
  zone           = data.ibm_is_zones.mzr.zones[0]
  resource_group = local.resource_group
  tags           = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "project:${local.name}"])
}

module "security" {
  source                 = "./security"
  name                   = var.name
  vpc_id                 = local.vpc.id
  bastion_security_group = module.vpc-bastion.bastion_maintenance_group_id
  resource_group         = local.resource_group
}

module "bastion" {
  count             = var.existing_bastion_instance != "" ? 0 : 1
  source            = "we-work-in-the-cloud/vpc-bastion/ibm"
  version           = "0.0.7"
  name              = "${local.name}-bastion"
  resource_group_id = data.ibm_resource_group.group.id
  vpc_id            = local.vpc.id
  subnet_id         = local.bastion_subnet_id
  ssh_key_ids       = local.ssh_key_ids
  allow_ssh_from    = var.allow_ssh_from
  create_public_ip  = var.create_public_ip
  image_name        = "ibm-ubuntu-20-04-minimal-amd64-2"
  init_script       = file("${path.module}/install.yml")
  tags              = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_zones.mzr.zones[0]}", "project:${local.name}"])
}

module "wireguard" {
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = var.vpc_id
  subnet_id         = local.bastion_subnet_id
  ssh_keys          = local.ssh_key_ids
  resource_group    = data.ibm_resource_group.group.id
  name              = "${local.name}-vpn"
  zone              = data.ibm_is_zones.mzr.zones[0]
  allow_ip_spoofing = true
  security_group_id = module.security.wireguard_security_group
  tags              = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_zones.mzr.zones[0]}", "project:${local.name}"])
  user_data         = file("${path.module}/install.yml")
}

resource "ibm_is_floating_ip" "wireguard" {
  name           = "${local.name}-wireguard-address"
  resource_group = data.ibm_resource_group.group.id
  target         = module.wireguard.instance.primary_network_interface.0.id
  tags           = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_zones.mzr.zones[0]}", "project:${local.name}"])
}

# Add Wireguard main interface to bastion security group to the Ansible playbook will run 
resource "ibm_is_security_group_network_interface_attachment" "under_maintenance" {
  depends_on        = [module.wireguard]
  network_interface = module.wireguard.instance.primary_network_interface.0.id
  security_group    = module.bastion.bastion_maintenance_group_id
}

module "ansible" {
  source               = "./ansible"
  bastion              = module.bastion.bastion_public_ip
  wireguard_instance   = module.wireguard.instance
  region               = var.region
  cse_addresses        = join(", ", flatten(local.vpc.cse_source_addresses[*].address))
  subnets              = local.subnets
  client_private_key   = var.client_private_key
  client_public_key    = var.client_public_key
  client_preshared_key = var.client_preshared_key
}
