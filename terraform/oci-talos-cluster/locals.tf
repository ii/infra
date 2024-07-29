locals {
  common_labels = {
    "TalosCluster" = var.cluster_name
  }
  talos_schematic     = jsondecode(data.http.talos_schematic.response_body).id
  talos_install_image = "factory.talos.dev/installer/${local.talos_schematic}:${var.talos_version}"
}
