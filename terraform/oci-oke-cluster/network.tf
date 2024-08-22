resource "oci_core_vcn" "vcn" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  cidr_blocks    = var.cidr_blocks
  display_name   = "${var.cluster_name}-vcn"
  freeform_tags  = local.common_labels
  is_ipv6enabled = true
}
resource "oci_core_subnet" "subnet" {
  #Required
  cidr_block                 = var.subnet_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false

  #Optional
  display_name      = "${var.cluster_name}-subnet"
  freeform_tags     = local.common_labels
  security_list_ids = [oci_core_security_list.security_list.id]
  route_table_id    = oci_core_route_table.route_table.id
}
resource "oci_core_subnet" "node_subnet" {
  #Required
  cidr_block                 = var.node_subnet_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false

  #Optional
  display_name      = "${var.cluster_name}-subnet"
  freeform_tags     = local.common_labels
  security_list_ids = [oci_core_security_list.security_list.id]
  route_table_id    = oci_core_route_table.route_table.id
}
resource "oci_core_route_table" "route_table" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name  = "${var.cluster_name}-route-table"
  freeform_tags = local.common_labels
  route_rules {
    #Required
    network_entity_id = oci_core_internet_gateway.internet_gateway.id

    #Optional
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  enabled       = true
  display_name  = "${var.cluster_name}-internet-gateway"
  freeform_tags = local.common_labels
}

resource "oci_core_network_security_group" "network_security_group" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name  = "${var.cluster_name}-security-group"
  freeform_tags = local.common_labels
}
resource "oci_core_network_security_group_security_rule" "allow_all" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  protocol                  = "all"
  direction                 = "EGRESS"
  stateless                 = false
}

resource "oci_core_security_list" "security_list" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name = "${var.cluster_name}-security-list"
  egress_security_rules {
    #Required
    destination = "0.0.0.0/0"
    protocol    = "all"

    stateless = true
  }
  freeform_tags = local.common_labels
  ingress_security_rules {
    #Required
    source   = "0.0.0.0/0"
    protocol = "all"

    stateless = true
  }
}
