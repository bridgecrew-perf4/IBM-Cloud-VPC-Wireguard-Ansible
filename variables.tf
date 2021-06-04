variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
  default     = "us-south"
}

variable "resource_group" {
  type        = string
  description = "Resource group where resources will be deployed."
  default     = "CDE"
}

variable "remote_addresses" {
  default = ["172.104.198.57", "76.31.10.241"]
}

variable "tags" {
  default = ["owner:ryantiffany"]
}

variable "existing_vpc" {}

variable "existing_subnet_id" {}
variable "name" {}
variable "ssh_key" {}
variable "allow_ssh_from" {}
variable "create_public_ip" {
  type    = bool
  default = true
}