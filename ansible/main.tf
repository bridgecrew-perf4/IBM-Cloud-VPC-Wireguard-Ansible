resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      bastion            = var.bastion
      wireguard_instance = var.wireguard_instance
    }
  )
  filename = "${path.module}/inventory"
}

resource "local_file" "ansible-vars" {
  content = templatefile("${path.module}/templates/vars.tmpl",
    {
      region               = var.region
      wireguard_instance   = var.wireguard_instance
      client_preshared_key = var.client_preshared_key
      client_public_key    = var.client_public_key
    }
  )
  filename = "${path.module}/playbooks/vars.yml"
}

resource "local_file" "wireguard-local-template" {
  content = templatefile("${path.module}/templates/wireguard-client.tmpl",
    {
      subnet             = var.subnet
      cse_addresses      = var.cse_addresses
      bastion            = var.bastion
      client_private_key = var.client_private_key
    }
  )
  filename = "${path.module}/templates/wireguard-client.j2"
}



