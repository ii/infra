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
  value = random_bytes.authentik_coder_oidc_client_id.hex
}
output "authentik_coder_oidc_client_secret" {
  value = random_bytes.authentik_coder_oidc_client_secret.hex
}
output "coder_admin_password" {
  value = random_string.coder_first_user_password.result
}
output "coder_admin_email" {
  value = "coder@ii.coop" # we may want to set this elsewhere
}
