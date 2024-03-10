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
  value = random_string.authentik_coder_oidc_client_id.result
}
output "authentik_coder_oidc_client_secret" {
  value = random_string.authentik_coder_oidc_client_secret.result
}
