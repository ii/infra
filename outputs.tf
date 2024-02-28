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
