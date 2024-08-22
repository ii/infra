resource "oci_containerengine_cluster" "cluster" {
  #Required
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.cluster_kubernetes_version
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.vcn.id

  endpoint_config {

    #Optional
    is_public_ip_enabled = true
    nsg_ids              = [oci_core_network_security_group.network_security_group.id]
    subnet_id            = oci_core_subnet.subnet.id
  }
  options {

    #Optional
    add_ons {

      #Optional
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    admission_controller_options {

      #Optional
      is_pod_security_policy_enabled = false
    }
    kubernetes_network_config {

      #Optional
      pods_cidr     = var.pod_subnet_block
      services_cidr = var.service_subnet_block
    }
    persistent_volume_config {

      #Optional
      freeform_tags = local.common_labels
    }
    service_lb_config {

      #Optional
      freeform_tags = local.common_labels
    }
    service_lb_subnet_ids = [oci_core_subnet.subnet.id]
  }
  type = "ENHANCED_CLUSTER"
}

resource "oci_containerengine_node_pool" "node_pool" {
  #Required
  cluster_id     = oci_containerengine_cluster.cluster.id
  compartment_id = var.compartment_ocid
  name           = "${var.cluster_name}-primary"
  node_shape     = var.node_shape

  #Optional
  freeform_tags      = local.common_labels
  kubernetes_version = var.cluster_kubernetes_version
  node_config_details {
    #Required
    placement_configs {
      #Required
      availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    size = var.node_pool_count

    freeform_tags = local.common_labels
    nsg_ids       = [oci_core_network_security_group.network_security_group.id]
  }
  node_shape_config {
    #Optional
    memory_in_gbs = var.node_memory_in_gbs
    ocpus         = var.node_ocpus
  }
  node_source_details {
    #Required
    image_id    = lookup(data.oci_core_images.node_pool_images.images[0], "id")
    source_type = "IMAGE"
  }
}
