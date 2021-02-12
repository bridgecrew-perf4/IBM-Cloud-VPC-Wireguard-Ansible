resource "ibm_is_instance" "regional_bastion" {
  name    = "${var.name}-bastion"
  image   = data.ibm_is_image.default.id
  profile = var.default_instance_profile

  primary_network_interface {
    subnet          = var.frontend_subnet[0]
    security_groups = [var.maintenance_sg_id]
  }

  resource_group = var.resource_group
  tags           = concat(var.tags, ["resource_type:vpc_compute", "workload:bastion", "zone:${var.zones[0]}"])

  vpc       = var.vpc_id
  zone      = var.zones[0]
  keys      = var.ssh_keys
  user_data = var.user_data
}

resource "ibm_is_instance" "region_consul_instances" {
  count   = length(var.zones)
  name    = "${var.name}-${var.zones[count.index]}-consul"
  image   = data.ibm_is_image.default.id
  profile = var.default_instance_profile

  primary_network_interface {
    subnet          = element(var.services_subnet[*], count.index)
    security_groups = [var.services_sg_id]
  }

  resource_group = var.resource_group
  tags           = concat(var.tags, ["resource_type:vpc_compute", "workload:bastion", "zone:${element(var.zones[*], count.index)}"])

  vpc       = var.vpc_id
  zone      = var.zones[count.index]
  keys      = var.ssh_keys
  user_data = var.user_data
}