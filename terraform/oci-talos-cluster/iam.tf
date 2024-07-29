resource "oci_identity_dynamic_group" "instance_dynamic_group" {
  #Required
  compartment_id = var.tenancy_ocid
  description    = "Instance access"
  matching_rule  = <<EOF
allow dynamic-group ${var.cluster_name}-instance-access to read instance-family in compartment ${var.oci_identity_compartment.this.name}
allow dynamic-group ${var.cluster_name}-instance-access to use virtual-network-family in compartment ${var.oci_identity_compartment.this.name}
allow dynamic-group ${var.cluster_name}-instance-access to manage load-balancers in compartment ${var.oci_identity_compartment.this.name}
allow dynamic-group ${var.cluster_name}-instance-access to manage volume-family in compartment ${var.oci_identity_compartment.this.name}
EOF
  name           = "${var.cluster_name}-instance-access"

  #Optional
  freeform_tags = local.common_labels
}
