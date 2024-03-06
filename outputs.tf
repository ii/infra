output "sharing-io-talosconfig" {
  value     = module.sharing-io.talosconfig
  sensitive = true
}

output "sharing-io-kubeconfig" {
  value     = module.sharing-io.kubeconfig
  sensitive = true
}

output "sharing-io-cluster-virtual-ip" {
  value = module.sharing-io.cluster_virtual_ip
}
