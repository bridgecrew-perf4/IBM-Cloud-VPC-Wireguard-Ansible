locals {
  ssh_key_ids    = var.existing_ssh_key != "" ? [data.ibm_is_ssh_key.existing_ssh_key.0.id, ibm_is_ssh_key.generated_key.id] : [ibm_is_ssh_key.generated_key.id]
  resource_group = var.existing_resource_group != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "generated_key" {
  name           = "${var.name}-${var.region}-key2"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = local.resource_group
  tags           = concat(var.tags, ["region:${var.region}", "project:${var.name}", "owner:${var.owner}"])
}

resource "ibm_resource_group" "group" {
  count = var.existing_resource_group != "" ? 0 : 1
  name  = "${var.name}-resource-group"
  tags  = concat(var.tags, ["project:${var.name}", "owner:${var.owner}"])
}

module "security" {
  source                 = "./security"
  name                   = var.name
  vpc                    = data.ibm_is_vpc.existing_vpc.id
  bastion_security_group = module.bastion.0.bastion_maintenance_group_id
  resource_group         = local.resource_group
}

module "bastion" {
  count             = var.existing_bastion_instance != "" ? 0 : 1
  source            = "we-work-in-the-cloud/vpc-bastion/ibm"
  version           = "0.0.7"
  name              = "${var.name}-bastion"
  resource_group_id = local.resource_group
  vpc_id            = data.ibm_is_vpc.existing_vpc.id
  subnet_id         = data.ibm_is_subnet.existing_subnet.id
  ssh_key_ids       = local.ssh_key_ids
  allow_ssh_from    = var.allow_ssh_from
  create_public_ip  = var.create_public_ip
  image_name        = "ibm-ubuntu-20-04-minimal-amd64-2"
  init_script       = file("${path.module}/install.yml")
  tags              = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_subnet.existing_subnet.zone}", "project:${var.name}"])
}

module "wireguard" {
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = data.ibm_is_vpc.existing_vpc.id
  subnet_id         = data.ibm_is_subnet.existing_subnet.id
  ssh_keys          = local.ssh_key_ids
  resource_group_id = local.resource_group
  name              = "${var.name}-vpn"
  zone              = data.ibm_is_subnet.existing_subnet.zone
  allow_ip_spoofing = true
  security_groups   = [module.bastion.0.bastion_maintenance_group_id, module.security.wireguard_security_group]
  tags              = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_subnet.existing_subnet.zone}", "project:${var.name}"])
  user_data         = file("${path.module}/install.yml")
}

module "instance" {
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = data.ibm_is_vpc.existing_vpc.id
  subnet_id         = data.ibm_is_subnet.existing_subnet.id
  ssh_keys          = local.ssh_key_ids
  resource_group_id = local.resource_group
  name              = "${var.name}-instance"
  zone              = data.ibm_is_subnet.existing_subnet.zone
  allow_ip_spoofing = true
  security_groups   = [module.bastion.0.bastion_maintenance_group_id, module.security.internal_security_group]
  tags              = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_subnet.existing_subnet.zone}", "project:${var.name}"])
  user_data         = file("${path.module}/install.yml")
}

resource "ibm_is_floating_ip" "wireguard" {
  name           = "${var.name}-wireguard-address"
  resource_group = local.resource_group
  target         = module.wireguard.instance.primary_network_interface.0.id
  tags           = concat(var.tags, ["region:${var.region}", "owner:${var.owner}", "zone:${data.ibm_is_subnet.existing_subnet.zone}", "project:${var.name}"])
}

# Add Wireguard main interface to bastion security group to the Ansible playbook will run 
resource "ibm_is_security_group_network_interface_attachment" "under_maintenance" {
  depends_on        = [module.wireguard]
  network_interface = module.wireguard.instance.primary_network_interface.0.id
  security_group    = module.bastion.0.bastion_maintenance_group_id
}

module "ansible" {
  source               = "./ansible"
  bastion              = module.bastion.0.bastion_public_ip
  wireguard_instance   = module.wireguard.instance.primary_network_interface.0.primary_ipv4_address
  region               = var.region
  cse_addresses        = join(", ", flatten(data.ibm_is_vpc.existing_vpc.cse_source_addresses[*].address))
  subnet               = data.ibm_is_subnet.existing_subnet.ipv4_cidr_block
  client_private_key   = var.client_private_key
  client_public_key    = var.client_public_key
  client_preshared_key = var.client_preshared_key
}


