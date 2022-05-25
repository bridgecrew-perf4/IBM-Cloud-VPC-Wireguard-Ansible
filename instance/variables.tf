variable "vpc_id" {}
variable "resource_group_id" {}
variable "security_group" {}
variable "subnet_id" {}
variable "zone" {}
variable "tags" {}
variable "allow_ip_spoofing" {
  default = false
}
variable "ssh_keys" {}
variable "name" {}
variable "metadata_service_enabled" {
  default = true
}

variable "instance_profile" {
  type        = string
  description = "The default instance profile size."
  default     = "cx2-2x4"
}

variable "instance_image" {
  type        = string
  description = "The default OS image to load on to the compute instances."
  default     = "u22-base-image"
}

variable "user_data" {
  default = ""
}
