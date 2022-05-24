resource "ibm_is_instance" "instance" {
  name                     = var.name
  vpc                      = var.vpc_id
  image                    = data.ibm_is_image.base.id
  profile                  = var.instance_profile
  resource_group           = var.resource_group_id
  metadata_service_enabled = var.metadata_service_enabled

  boot_volume {
    name = "${var.name}-boot-volume"
  }

  primary_network_interface {
    subnet            = var.subnet_id
    allow_ip_spoofing = var.allow_ip_spoofing
    security_groups   = var.security_group
  }

  user_data = var.user_data != "" ? var.user_data : file("${path.module}/init.yml")
  zone      = var.zone
  keys      = var.ssh_keys
  tags      = var.tags

}
