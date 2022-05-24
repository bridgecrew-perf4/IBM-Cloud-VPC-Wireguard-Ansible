output "wireguard_public_ip" {
  value = ibm_is_floating_ip.wireguard_public.address
}

output "wireguard_private_ip" {
  value = module.wireguard_server.private_ipv4_address
}

output "podman_private_ip" {
  value = module.podman_instance.private_ipv4_address
}

output "ssh_command" {
  description = "Command to test our access to the podman instance via our wireguard instance."
  value       = "ssh -o StrictHostKeyChecking=no -o ProxyCommand='ssh -o StrictHostKeyChecking=no -W %h:%p root@${ibm_is_floating_ip.wireguard_public.address}' root@${module.podman_instance.private_ipv4_address}"

}