output "talosconfig" {
  value     = module.cloudnative-coop.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.cloudnative-coop.kubeconfig
  sensitive = true
}
