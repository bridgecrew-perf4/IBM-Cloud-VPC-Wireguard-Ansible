locals {
  ssh_key_ids          = var.existing_ssh_key != "" ? [data.ibm_is_ssh_key.existing_ssh_key.0.id, ibm_is_ssh_key.generated_key.id] : [ibm_is_ssh_key.generated_key.id]
  vpc_id               = var.existing_vpc != "" ? data.ibm_is_vpc.existing_vpc.0.id : ibm_is_vpc.new_vpc.0.id
  resource_group       = var.existing_resource_group != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
  frontend_subnet      = var.existing_subnet_name != "" ? data.ibm_is_subnet.existing_subnet.0.id : ibm_is_subnet.frontend_subnet.0.id
  frontend_subnet_cidr = var.existing_subnet_name != "" ? data.ibm_is_subnet.existing_subnet.0.ipv4_cidr_block : ibm_is_subnet.frontend_subnet.0.ipv4_cidr_block
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "generated_key" {
  name           = "${var.name}-${var.region}-key"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = local.resource_group
  tags           = concat(var.tags, ["region:${var.region}", "project:${var.name}", "owner:${var.owner}"])
}

resource "ibm_resource_group" "group" {
  count = var.existing_resource_group != "" ? 0 : 1
  name  = "${var.name}-resource-group"
  tags  = concat(var.tags, ["project:${var.name}", "owner:${var.owner}"])
}

resource "ibm_is_vpc" "new_vpc" {
  count = var.existing_vpc != "" ? 0 : 1
  name  = "${var.name}-vpc"
  tags  = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}"])
}

resource "ibm_is_public_gateway" "frontend" {
  name           = "${var.name}-frontend-pubgw"
  vpc            = local.vpc_id
  zone           = data.ibm_is_zones.mzr.zones[0]
  resource_group = local.resource_group
  tags           = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}"])
}

resource "ibm_is_subnet" "frontend_subnet" {
  count                    = var.existing_subnet_name != "" ? 0 : 1
  name                     = "${var.name}-frontend-subnet"
  vpc                      = local.vpc_id
  zone                     = data.ibm_is_zones.mzr.zones[0]
  total_ipv4_address_count = "16"
  resource_group           = local.resource_group
  public_gateway           = ibm_is_public_gateway.frontend.id
  tags                     = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}"])
}

resource "ibm_is_subnet" "backend_subnet" {
  name                     = "${var.name}-backend-subnet"
  vpc                      = local.vpc_id
  zone                     = data.ibm_is_zones.mzr.zones[0]
  total_ipv4_address_count = "64"
  resource_group           = local.resource_group
  tags                     = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}"])
}

module "security" {
  source            = "./security"
  name              = var.name
  vpc_id            = local.vpc_id
  resource_group_id = local.resource_group
  allow_ssh_from    = var.allow_ssh_from
  allow_tunnel_from = var.allow_tunnel_from
  tags              = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}"])
}

module "wireguard_server" {
  source            = "./instance"
  vpc_id            = local.vpc_id
  name              = "${var.name}-wg-server"
  resource_group_id = local.resource_group
  security_group    = [module.security.frontend_security_group]
  subnet_id         = local.frontend_subnet
  zone              = data.ibm_is_zones.mzr.zones[0]
  ssh_keys          = local.ssh_key_ids
  allow_ip_spoofing = true
  tags              = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
}

resource "ibm_is_floating_ip" "wireguard_public" {
  name           = "${var.name}-wg-public-ip"
  target         = module.wireguard_server.primary_network_interface
  resource_group = local.resource_group
  tags           = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
}

module "podman_instance" {
  source            = "./instance"
  name              = "${var.name}-podman-instance"
  vpc_id            = local.vpc_id
  resource_group_id = local.resource_group
  security_group    = [module.security.backend_security_group]
  subnet_id         = ibm_is_subnet.backend_subnet.id
  zone              = data.ibm_is_zones.mzr.zones[0]
  ssh_keys          = local.ssh_key_ids
  tags              = concat(var.tags, ["project:${var.name}", "owner:${var.owner}", "region:${var.region}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
}

module "ansible" {
  source                  = "./ansible"
  podman_instance         = module.podman_instance.private_ipv4_address
  wireguard_instance      = ibm_is_floating_ip.wireguard_public.address
  client_peer_allowed_ips = var.client_peer_allowed_ips
  client_public_key       = var.client_public_key
  local_ip                = var.local_ip
  frontend_subnet_cidr    = local.frontend_subnet_cidr
  backend_subnet_cidr     = ibm_is_subnet.backend_subnet.ipv4_cidr_block
}


