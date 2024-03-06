output "test-sharing-io-talosconfig" {
  value     = module.test-sharing-io.talosconfig
  sensitive = true
}

output "test-sharing-io-kubeconfig" {
  value     = module.test-sharing-io.kubeconfig
  sensitive = true
}

output "test-sharing-io-cluster-virtual-ip" {
  value = module.test-sharing-io.cluster_virtual_ip
}

output "test-sharing-io-cluster-ingress-ip" {
  value = module.test-sharing-io.cluster_ingress_ip
}

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
