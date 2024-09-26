resource "equinix_metal_reserved_ip_block" "cluster_apiserver_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1
  tags       = ["eip-apiserver-${var.cluster_name}"]
}

resource "equinix_metal_reserved_ip_block" "cluster_ingress_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1
  tags       = ["eip-ingress-${var.cluster_name}"]
}

resource "equinix_metal_reserved_ip_block" "cluster_dns_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1
  tags       = ["eip-dns-${var.cluster_name}"]
}

resource "equinix_metal_reserved_ip_block" "cluster_wireguard_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1
  tags       = ["eip-wireguard-${var.cluster_name}"]
}

module "cluster-record-apiserver-ip" {
  source = "../rfc2136-record-assign"

  zone      = "${var.domain}."
  name      = "k8s"
  addresses = [equinix_metal_reserved_ip_block.cluster_apiserver_ip.network]
}

module "cluster-record-ingress-ip" {
  source = "../rfc2136-record-assign"

  zone      = "${var.domain}."
  name      = "*"
  addresses = [equinix_metal_reserved_ip_block.cluster_ingress_ip.network]
}

module "cluster-record-dns-ip" {
  source = "../rfc2136-record-assign"

  zone      = "${var.domain}."
  name      = "dns"
  addresses = [equinix_metal_reserved_ip_block.cluster_dns_ip.network]
}

module "cluster-record-wireguard-ip" {
  source = "../rfc2136-record-assign"

  zone      = "${var.domain}."
  name      = "wireguard"
  addresses = [equinix_metal_reserved_ip_block.cluster_wireguard_ip.network]
}
