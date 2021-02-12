variable vpc_id {}
variable resource_group {}
variable name {}
variable frontend_subnet {}
variable services_subnet {}
variable zones {}
variable user_data {}
variable ssh_keys {}
variable maintenance_sg_id {}
variable services_sg_id {}
variable default_instance_profile {
  type    = string
  default = "bx2-2x8"
}
variable os_image {
  type        = string
  description = "OS Image to use for VPC instances. Default is currently Ubuntu 20."
  default     = "ibm-ubuntu-20-04-minimal-amd64-2"
}

variable tags {}