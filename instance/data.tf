data "ibm_is_image" "base" {
  visibility = "private"
  name       = var.instance_image
}
