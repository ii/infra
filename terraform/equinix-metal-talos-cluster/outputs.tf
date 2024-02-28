output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "cluster_virtual_ip" {
  value = equinix_metal_reserved_ip_block.cluster_virtual_ip.network
}
