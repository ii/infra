resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = [for k, v in oci_core_instance.cp : v.public_ip][0]
  node                 = [for k, v in oci_core_instance.cp : v.public_ip][0]
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}
