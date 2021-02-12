terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/state/ibmcloud-vpc-wireguard-ansible-terraform.tfstate"
  }
}
