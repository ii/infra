resource "oci_core_vcn" "vcn" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  cidr_blocks                      = var.cidr_blocks
  display_name                     = "${var.cluster_name}-vcn"
  dns_label                        = var.vcn_dns_label
  freeform_tags                    = local.common_labels
  ipv6private_cidr_blocks          = var.vcn_ipv6private_cidr_blocks
  is_ipv6enabled                   = var.vcn_is_ipv6enabled
  is_oracle_gua_allocation_enabled = var.vcn_is_oracle_gua_allocation_enabled
}
resource "oci_core_subnet" "subnet" {
  #Required
  cidr_block     = var.subnet_block
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name  = "${var.cluster_name}-subnet"
  freeform_tags = local.common_labels
}
resource "oci_core_route_table" "route_table" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name  = "${var.cluster_name}-route-table"
  freeform_tags = local.common_labels
  route_rules {
    #Required
    network_entity_id = oci_core_internet_gateway.internet_gateway.id

    #Optional
    cidr_block = "0.0.0.0/0"
  }
}
resource "oci_core_internet_gateway" "internet_gateway" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  enabled       = true
  display_name  = "${var.cluster_name}-internet-gateway"
  freeform_tags = local.common_labels
}

# TODO security-list?

resource "oci_load_balancer_load_balancer" "cp_load_balancer" {
  #Required
  compartment_id = var.compartment_id
  display_name   = "${var.cluster_name}-cp-load-balancer"
  shape          = "Flexible"
  subnet_ids     = [oci_core_subnet.subnet.id]

  #Optional
  freeform_tags = local.common_labels
  is_private    = false
  # TODO where is this option? --is-preserve-source-destination false
}
resource "oci_load_balancer_backend_set" "talos_backend_set" {
  #Required
  health_checker {
    #Required
    protocol = "TCP"
    #Optional
    interval_ms = 10000
    port        = 50000
  }
  load_balancer_id = oci_load_balancer_load_balancer.cp_load_balancer.id
  name             = "${var.cluster_name}-talos"
  policy           = "TWO_TUPLE"
  # TODO where is this option? --is-preserve-source false
}
resource "oci_load_balancer_listener" "talos_listener" {
  #Required
  default_backend_set_name = oci_load_balancer_backend_set.talos_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.cp_load_balancer.id
  name                     = "${var.cluster_name}-talos"
  port                     = 50000
  protocol                 = "TCP"
}
resource "oci_load_balancer_backend_set" "kubernetes_backend_set" {
  #Required
  health_checker {
    #Required
    protocol = "HTTPS"
    #Optional
    interval_ms = 10000
    port        = 6443
    return_code = 401
    url_path    = "/readyz"
  }
  load_balancer_id = oci_load_balancer_load_balancer.cp_load_balancer.id
  name             = "${var.cluster_name}-kubernetes"
  policy           = "TWO_TUPLE"
  # TODO where is this option? --is-preserve-source false
}
resource "oci_load_balancer_listener" "talos_listener" {
  #Required
  default_backend_set_name = oci_load_balancer_backend_set.talos_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.cp_load_balancer.id
  name                     = "${var.cluster_name}-kubernetes"
  port                     = 6443
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_backend" "talos_backend" {
  #Required
  backend_set_name         = "talos"
  network_load_balancer_id = oci_load_balancer_load_balancer.cp_load_balancer.id
  port                     = 50000

  #Optional
  target_id = oci_core_instance.cp.id
}

resource "oci_network_load_balancer_backend" "controlplane_backend" {
  #Required
  backend_set_name         = "controlplane"
  network_load_balancer_id = oci_load_balancer_load_balancer.cp_load_balancer.id
  port                     = 6443

  #Optional
  target_id = oci_core_instance.cp.id
}
