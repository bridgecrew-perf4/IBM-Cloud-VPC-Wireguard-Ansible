output regional_bastion {
  value = ibm_is_floating_ip.bastion.address
}

# output instance_names {
#     value = module.consul[*].instance.name
# }

# output instance_ips {
#     value = module.consul[*].primary_ip4_address
# }

output instances {
  value = formatlist("instance: %s ip %s", module.consul[*].instance.name, module.consul[*].primary_ip4_address)
}

output frontend_subnets {
  value = module.frontend_subnet[*].ipv4_cidr_block
}



