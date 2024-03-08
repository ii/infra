data "kubernetes_secret_v1" "receiver_token" {
  metadata {
    name      = "receiver-token"
    namespace = "flux-system"
  }
}

data "kubernetes_resource" "receiver" {
  api_version = "notification.toolkit.fluxcd.io/v1"
  kind        = "Receiver"

  metadata {
    name      = "github-receiver"
    namespace = "flux-system"
  }
}

data "github_repository" "self" {
  full_name = var.repo
}
