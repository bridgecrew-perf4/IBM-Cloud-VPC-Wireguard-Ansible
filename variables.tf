variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
  default     = "jp-osa"
}

variable "resource_group" {
  type        = string
  description = "Resource group where resources will be deployed."
  default     = "CDE"
}

variable remote_addresses {
  default = ["172.104.198.57", "76.31.10.241"]
}

variable tags {
  default = ["owner:ryantiffany"]
}

variable client_preshared_key {}
variable client_private_key {}
variable client_public_key {}
variable encrypt_key {}
variable acl_token {}
variable logdna_ingestion_key {}
variable sysdig_key {}