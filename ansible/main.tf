resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      podman_instance    = var.podman_instance
      wireguard_instance = var.wireguard_instance
    }
  )
  filename = "${path.module}/inventory"
}

resource "local_file" "ansible-vars" {
  content = templatefile("${path.module}/templates/vars.tmpl",
    {
      client_peer_allowed_ips = var.client_peer_allowed_ips
      client_public_key       = var.client_public_key
    }
  )
  filename = "${path.module}/playbooks/vars.yml"
}

resource "local_file" "wireguard-local-template" {
  content = templatefile("${path.module}/templates/wg0.client.j2",
    {
      local_ip             = var.local_ip
      wireguard_instance   = var.wireguard_instance
      backend_subnet_cidr  = var.backend_subnet_cidr
      frontend_subnet_cidr = var.frontend_subnet_cidr
    }
  )
  filename = "${path.module}/updated_client_config"
}

