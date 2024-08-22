data "oci_identity_compartment" "this" {
  id = var.compartment_ocid
}

data "oci_identity_availability_domains" "availability_domains" {
  #Required
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "node_pool_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.node_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_containerengine_cluster_kube_config" "cluster_kube_config" {
  #Required
  cluster_id = oci_containerengine_cluster.cluster.id
}
