resource "ibm_is_security_group" "wireguard_security_group" {
  name           = "${var.name}-wg-security-group"
  vpc            = var.vpc
  resource_group = var.resource_group
}

resource "ibm_is_security_group_rule" "wg_udp" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 51280
    port_max = 51280
  }
}

resource "ibm_is_security_group_rule" "ssh_from_bastion" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "inbound"
  remote    = var.bastion_security_group
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "ping" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}

# from https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc
resource "ibm_is_security_group_rule" "cse_dns_1" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "outbound"
  remote    = "161.26.0.10"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "cse_dns_2" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "outbound"
  remote    = "161.26.0.11"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "private_dns_1" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "outbound"
  remote    = "161.26.0.7"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "private_dns_2" {
  group     = ibm_is_security_group.wireguard_security_group.id
  direction = "outbound"
  remote    = "161.26.0.8"
  udp {
    port_min = 53
    port_max = 53
  }
}