resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      instances = var.instances
      bastion   = var.bastion
    }
  )
  filename = "${path.module}/inventory"
}

resource "local_file" "ansible-vars" {
  content = templatefile("${path.module}/templates/vars.tmpl",
    {
      encrypt_key          = var.encrypt_key
      region               = var.region
      logdna_ingestion_key = var.logdna_ingestion_key
      sysdig_key           = var.sysdig_key
      bastion              = var.bastion
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
    }
  )
  filename = "${path.module}/templates/wireguard-client.j2"
}



