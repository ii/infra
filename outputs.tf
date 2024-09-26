output "talosconfig" {
  value     = module.cluster.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.cluster.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "akadmin-password" {
  value     = module.cluster-manifests.authentik_bootstrap_password
  sensitive = true
}

output "akadmin-token" {
  value     = module.cluster-manifests.authentik_bootstrap_token
  sensitive = true
}

output "cluster-apiserver-ip" {
  value = module.cluster.cluster_apiserver_ip
}

output "cluster-ingress-ip" {
  value = module.cluster.cluster_ingress_ip
}
output "coder_admin_email" {
  value = module.cluster-manifests.coder_admin_email
}
output "coder_admin_password" {
  value     = module.cluster-manifests.coder_admin_password
  sensitive = true
}
