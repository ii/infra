output "flux_receiver_token" {
  value = random_string.flux_receiver_token.result
}
output "authentik_bootstrap_token" {
  value = random_string.authentik_bootstrap_token.result
}
output "authentik_bootstrap_password" {
  value = random_string.authentik_bootstrap_password.result
}
output "authentik_secret_key" {
  value = random_string.authentik_secret_key.result
}
output "authentik_coder_oidc_client_id" {
  value = random_password.authentik_coder_oidc_client_id.result
}
output "authentik_coder_oidc_client_secret" {
  value = random_password.authentik_coder_oidc_client_secret.result
}
output "coder_admin_password" {
  value = random_string.coder_first_user_password.result
}
output "coder_admin_email" {
  value = "coder@ii.coop" # we may want to set this elsewhere
}
output "authentik_config_hash" {
  value = sha1(jsonencode(merge(
    data.kubernetes_secret_v1.authentik_env.data,
    data.kubernetes_config_map_v1.authentik_env.data,
  )))
}
output "coder_config_hash" {
  value = sha1(jsonencode(merge(
    data.kubernetes_secret_v1.coder.data,
    data.kubernetes_config_map_v1.coder_kustomize.data,
    data.kubernetes_config_map_v1.coder_config.data,
  )))
}
