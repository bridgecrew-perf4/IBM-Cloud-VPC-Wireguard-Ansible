resource "ibm_is_security_group" "frontend_security_group" {
  name           = "${var.name}-frontend-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}

resource "ibm_is_security_group_rule" "frontend_vpn_udp_inbound" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = var.allow_tunnel_from
  udp {
    port_min = 51280
    port_max = 51280
  }
}

resource "ibm_is_security_group_rule" "frontend_ssh_inbound" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = var.allow_ssh_from
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "frontend_all_to_self" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = ibm_is_security_group.frontend_security_group.id
}

resource "ibm_is_security_group_rule" "frontend_inbound_from_backend" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = ibm_is_security_group.backend_security_group.id
}

resource "ibm_is_security_group_rule" "frontend_ping_inbound" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
    code = 0
  }
}

resource "ibm_is_security_group_rule" "frontend_all_out" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_security_group" "backend_security_group" {
  name           = "${var.name}-backend-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}


resource "ibm_is_security_group_rule" "backend_ping_inbound_from_frontend" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "inbound"
  remote    = ibm_is_security_group.frontend_security_group.id
  icmp {
    type = 8
    code = 0
  }
}

resource "ibm_is_security_group_rule" "backend_ping_inbound_from_self" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "inbound"
  remote    = ibm_is_security_group.backend_security_group.id
  icmp {
    type = 8
    code = 0
  }
}

resource "ibm_is_security_group_rule" "backend_ssh_from_frontend" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "inbound"
  remote    = ibm_is_security_group.frontend_security_group.id
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "backend_all_to_self" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "inbound"
  remote    = ibm_is_security_group.backend_security_group.id
}

resource "ibm_is_security_group_rule" "backend_all_out" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
