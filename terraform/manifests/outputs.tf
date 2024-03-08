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
