// TODO use instance pool?

resource "oci_core_instance" "controlplane" {
  count = 1
  #Required
  availability_domain = var.instance_availability_domain
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  shape_options = {
    ocpus         = 8
    memory_in_gbs = "128"
  }

  #Optional
  display_name                        = "${var.cluster_name}-control-plane"
  freeform_tags                       = local.common_labels
  hostname_label                      = "${var.cluster_name}-control-plane"
  ipxe_script                         = var.instance_ipxe_script
  is_pv_encryption_in_transit_enabled = var.instance_is_pv_encryption_in_transit_enabled
  launch_options {
    #Optional
    network_type = local.image_launch_mode
  }
  metadata = {
    "user_data" = data.talos_machine_configuration.machine_configuration
  }
  source_details {
    #Required
    source_id   = oci_core_image.talos_image.id
    source_type = "image"
  }
  preserve_boot_volume = false
}
