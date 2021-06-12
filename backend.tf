terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/remote-state/vpc-wg-terraform.tfstate"
  }
}
