output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "cluster_apiserver_ip" {
  value = equinix_metal_reserved_ip_block.cluster_apiserver_ip.network
}

output "cluster_ingress_ip" {
  value = equinix_metal_reserved_ip_block.cluster_ingress_ip.network
}

output "cluster_node0_ip" {
  value = { for idx, val in equinix_metal_device.cp : idx => val }[0].network.0.address
}
