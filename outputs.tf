output "sharing-io-talosconfig" {
  value     = module.sharing-io.talosconfig
  sensitive = true
}

output "sharing-io-kubeconfig" {
  value     = module.sharing-io.kubeconfig
  sensitive = true
}

output "sharing-io-cluster-apiserver-ip" {
  value = module.sharing-io.cluster_apiserver_ip
}

output "sharing-io-cluster-ingress-ip" {
  value = module.sharing-io.cluster_ingress_ip
}
