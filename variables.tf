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
  type        = list(string)
  description = "Tags that will be added to all resources that support them."
  default     = []
}

variable "existing_vpc" {
  type        = string
  description = "(Optional) Name of an existing VPC where wireguard instance will be deployed. If none provided a new one will be created."
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
  description = "(Optional) Name of an existing VPC ssh key for the region. If none provided a new one will be created."
}

variable "allow_ssh_from" {
  type        = string
  description = "(Optional) An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the bastion instance. If none provided then SSH is open to `0.0.0.0/0`."
  default     = "0.0.0.0/0"
}

variable "allow_tunnel_from" {
  type        = string
  description = "(Optional) An IP address or CIDR block that is allowed to connect to the Wireguard Instance tunnel. If none provided then the tunnel is open to `0.0.0.0/0`."
  default     = "0.0.0.0/0"
}

variable "client_public_key" {
  type        = string
  description = "Wireguard local client Public Key"
}

variable "client_peer_allowed_ips" {
  type        = string
  description = "The local subnet allowed on the remote side of the connection. For example: 192.168.0.0/24"
}

variable "owner" {
  type        = string
  description = "A username to add as a tag to all deployed resources that support tagging. Tag will be in the format `owner:your_user_name`."
  default     = "ryantiffany"
}

variable "local_ip" {
  default = "192.168.4.143/32"
}
