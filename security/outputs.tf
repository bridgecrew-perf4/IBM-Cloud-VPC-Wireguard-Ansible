output "wireguard_security_group" {
  value = ibm_is_security_group.wireguard_security_group.id
}

output "internal_security_group" {
  value = ibm_is_security_group.internal_security_group.id
}