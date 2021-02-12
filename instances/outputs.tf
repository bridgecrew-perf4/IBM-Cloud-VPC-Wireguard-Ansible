output bastion_interface_id {
  value = ibm_is_instance.regional_bastion.primary_network_interface[0].id
}