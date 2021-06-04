# resource "ibm_is_security_group" "maintenance_security_group" {
#   name           = "${var.name}-maintenance-security-group"
#   vpc            = var.vpc
#   resource_group = var.resource_group
# }

# resource "ibm_is_security_group_rule" "maintenance_ssh_in" {
#   count     = length(var.remote_addresses)
#   group     = ibm_is_security_group.maintenance_security_group.id
#   direction = "inbound"
#   remote    = element(var.remote_addresses[*], count.index)
#   tcp {
#     port_min = 22
#     port_max = 22
#   }
# }

# resource "ibm_is_security_group_rule" "maintenance_http_in" {
#   count     = length(var.remote_addresses)
#   group     = ibm_is_security_group.maintenance_security_group.id
#   direction = "inbound"
#   remote    = element(var.remote_addresses[*], count.index)
#   tcp {
#     port_min = 80
#     port_max = 80
#   }
# }

# resource "ibm_is_security_group_rule" "maintenance_https_in" {
#   count     = length(var.remote_addresses)
#   group     = ibm_is_security_group.maintenance_security_group.id
#   direction = "inbound"
#   remote    = element(var.remote_addresses[*], count.index)
#   tcp {
#     port_min = 443
#     port_max = 443
#   }
# }

# resource "ibm_is_security_group_rule" "maintenance_vpn_in" {
#   group     = ibm_is_security_group.maintenance_security_group.id
#   direction = "inbound"
#   remote    = "0.0.0.0/0"
#   udp {
#     port_min = 51820
#     port_max = 51820
#   }
# }

# resource "ibm_is_security_group_rule" "mainteance_all_out" {
#   group     = ibm_is_security_group.maintenance_security_group.id
#   direction = "outbound"
#   remote    = "0.0.0.0/0"
# }

# resource "ibm_is_security_group" "services_security_group" {
#   name           = "${var.name}-services-security-group"
#   vpc            = var.vpc_id
#   resource_group = var.resource_group
# }

# resource "ibm_is_security_group_rule" "services_in_from_frontend" {
#   count     = length(var.frontend_subnet)
#   group     = ibm_is_security_group.services_security_group.id
#   direction = "inbound"
#   remote    = element(var.frontend_subnet[*], count.index)
# }

# resource "ibm_is_security_group_rule" "services_in_from_itself" {
#   count     = length(var.services_subnet)
#   group     = ibm_is_security_group.services_security_group.id
#   direction = "inbound"
#   remote    = element(var.services_subnet[*], count.index)
# }

# resource "ibm_is_security_group_rule" "services_all_out" {
#   group     = ibm_is_security_group.services_security_group.id
#   direction = "outbound"
#   remote    = "0.0.0.0/0"
# }