variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key used to deploy resources."
}

variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
}

variable "existing_resource_group" {
  type        = string
  description = "(Optional) The name of the Resource group where resources will be deployed. If none provided a new one will be created."
}

variable "tags" {
  default = ["owner:ryantiffany"]
}

variable "existing_vpc_name" {
  type        = string
  description = "Name of an existing VPC where wireguard instance will be deployed."
  default     = ""
}

variable "existing_subnet_name" {
  type        = string
  description = "Name of an existing VPC Subnet where resources will be deployed."
}

variable "name" {
  type        = string
  description = "Name to prepend to all deployed resources."
}

variable "existing_ssh_key" {
  type        = string
  description = "(Optional) Name of an existing VPC ssh key for the region. If not provided a new key will be generated and attached to the Wireguard instance."
}

variable "allow_ssh_from" {
  type        = string
  description = "(Optional) An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the bastion instance. If none provided then SSH is open to `0.0.0.0/0`."
  default     = "0.0.0.0/0"
}

variable "create_public_ip" {
  type        = bool
  description = "Set whether to allocate a public IP address for the bastion instance."
  default     = true
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

