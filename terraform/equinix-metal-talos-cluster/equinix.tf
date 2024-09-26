
resource "random_pet" "random" {
  count  = var.controlplane_nodes
  length = 2
}

resource "equinix_metal_device" "cp" {
  for_each = { for idx, val in random_pet.random : idx => val }
  # hostname = "${var.cluster_name}-${each.value.id}"
  hostname         = "${each.value.id}.${var.domain}"
  plan             = var.equinix_metal_plan
  metro            = var.equinix_metal_metro
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = var.equinix_metal_project_id
  # https://github.com/siderolabs/image-factory?tab=readme-ov-file#get-pxeschematicversionpath
  ipxe_script_url = local.ipxe_script_url
  always_pxe      = "false"
}

module "dns-record-node-ip" {
  for_each = { for idx, val in equinix_metal_device.cp : idx => val }
  source   = "../rfc2136-record-assign"

  zone      = "${var.domain}."
  name      = element(split(".", each.value.hostname), 0)
  addresses = [each.value.access_public_ipv4]

  providers = {
    dns = dns
  }
}

resource "equinix_metal_bgp_session" "cp_bgp" {
  for_each       = { for idx, val in equinix_metal_device.cp : idx => val }
  device_id      = each.value.id
  address_family = "ipv4"
}

data "equinix_metal_device_bgp_neighbors" "bgp_neighbor" {
  for_each = { for idx, val in equinix_metal_device.cp : idx => val }
  # NOTE consider including a for_each to iterate and have one for server
  device_id = each.value.id
}
