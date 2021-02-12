
data "ibm_resource_group" "cde" {
  name = var.resource_group
}

data "ibm_is_zones" "mzr" {
  region = var.region
}

data "ibm_is_ssh_key" "regional_tycho_key" {
  name = "tycho-${var.region}"
}

data "ibm_is_ssh_key" "hyperion_regional_key" {
  name = "hyperion-${var.region}"
}

data "ibm_is_ssh_key" "malachor_regional_key" {
  name = "malachor-${var.region}"
}

data "ibm_is_ssh_key" "mercury_regional_key" {
  name = "mercury-${var.region}"
}
