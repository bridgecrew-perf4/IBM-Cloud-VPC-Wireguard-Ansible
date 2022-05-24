output "frontend_security_group" {
  value = ibm_is_security_group.frontend_security_group.id
}

output "backend_security_group" {
  value = ibm_is_security_group.backend_security_group.id
}