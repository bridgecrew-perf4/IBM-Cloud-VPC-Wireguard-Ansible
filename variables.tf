variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
}

variable "resource_group" {
  type        = string
  description = "Resource group where resources will be deployed."
}

variable "tags" {
  default = ["owner:ryantiffany"]
}

variable "existing_vpc" {
  type        = string
  description = "(Optional) Name of an existing VPC where resources will be deployed. If none provided a new VPC will be created."
  default     = ""
}

variable "existing_subnet_id" {
  type        = string
  description = "(Optional) ID of an existing VPC Subnet where resources will be deployed. To use this `existing_vpc` must be set too. If none provided a new Subnet will be created."
  default     = ""
}

variable "name" {
  type        = string
  description = "(Optional) Name to prepend to all deployed resources. If none provided it default to `wg`."
  default     = "wg"
}

variable "ssh_key" {
  type        = string
  description = "(Optional) Name of an existing VPC ssh key for the region. If not provided a new key will be generated and attached to the Wireguard instance."
}

variable "allow_ssh_from" {
  type        = string
  description = "(Optional) An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the wireguard instance. If none provided then SSH is open to `0.0.0.0/0`."
}

variable "create_public_ip" {
  type        = bool
  description = "Set whether to allocate a public IP address for the wireguard instance"
  default     = true
}

variable "zone" {
  type        = string
  description = "VPC zone where Wireguard instance is deployed. If using an existing Subnet make sure you target the correct zone. Options are 1,2, or 3 and correspond to `var.region-N` (us-south- for example). "
}

variable "client_public_key" {
  type        = string
  description = "Wireguard local client Public Key"
}

variable "client_preshared_key" {
  type        = string
  description = "Wireguard local client Preshared Key."
}

variable "client_private_key" {
  type        = string
  description = "Wireguard local client private key"
}

variable "existing_bastion_instance" {
  type        = string
  description = "Name of an existing bastion instance"
  default     = ""
}