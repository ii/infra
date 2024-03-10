output "github_repository_deploy_key" {
  value = tls_private_key.flux.private_key_pem
}
