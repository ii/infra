resource "oci_core_image" "talos_image" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  display_name  = "Talos ${var.talos_version}"
  launch_mode   = local.image_launch_mode
  freeform_tags = local.common_labels

  image_source_details {
    source_type = "objectStorageUri"
    source_uri  = local.talos_disk_image_url

    #Optional
    operating_system         = "Talos Linux"
    operating_system_version = var.talos_version
    source_image_type        = "QCOW2"
  }
}
