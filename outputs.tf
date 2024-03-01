output "cloudnative-coop-talosconfig" {
  value     = module.cloudnative-coop.talosconfig
  sensitive = true
}

output "cloudnative-coop-kubeconfig" {
  value     = module.cloudnative-coop.kubeconfig
  sensitive = true
}

output "cloudnative-coop-cluster-virtual-ip" {
  value = module.cloudnative-coop.cluster_virtual_ip
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
