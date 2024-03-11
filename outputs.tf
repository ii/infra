output "sharing-io-talosconfig" {
  value     = module.sharing-io.talosconfig
  sensitive = true
}

output "sharing-io-kubeconfig" {
  value     = module.sharing-io.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "sharing-io-akadmin-password" {
  value     = module.sharing-io-manifests.authentik_bootstrap_password
  sensitive = true
}

output "sharing-io-akadmin-token" {
  value     = module.sharing-io-manifests.authentik_bootstrap_token
  sensitive = true
}

output "sharing-io-cluster-apiserver-ip" {
  value = module.sharing-io.cluster_apiserver_ip
}

output "sharing-io-cluster-ingress-ip" {
  value = module.sharing-io.cluster_ingress_ip
}
output "coder_admin_email" {
  value = module.sharing-io-manifests.coder_admin_email
}
output "coder_admin_password" {
  value     = module.sharing-io-manifests.coder_admin_password
  sensitive = true
}
