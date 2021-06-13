resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      bastion = var.bastion
    }
  )
  filename = "${path.module}/inventory"
}

resource "local_file" "ansible-vars" {
  content = templatefile("${path.module}/templates/vars.tmpl",
    {
      region               = var.region
      bastion              = var.bastion
      client_preshared_key = var.client_preshared_key
      client_public_key    = var.client_public_key
    }
  )
  filename = "${path.module}/playbooks/vars.yml"
}

resource "local_file" "wireguard-local-template" {
  content = templatefile("${path.module}/templates/wireguard-client.tmpl",
    {
      subnets            = var.subnets
      cse_addresses      = var.cse_addresses
      bastion            = var.bastion
      client_private_key = var.client_private_key
    }
  )
  filename = "${path.module}/templates/wireguard-client.j2"
}



