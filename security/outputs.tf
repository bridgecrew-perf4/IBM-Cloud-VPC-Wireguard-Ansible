output maintenance_sg_id {
  value = ibm_is_security_group.maintenance_security_group.id
}

output services_sg_id {
  value = ibm_is_security_group.services_security_group.id
}