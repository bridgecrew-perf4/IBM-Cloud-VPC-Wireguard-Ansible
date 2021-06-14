output "bastion_public_ip" {
  value = module.bastion.0.bastion_public_ip
}

output "wireguard_public_ip" {
  value = ibm_is_floating_ip.wireguard.address
}
