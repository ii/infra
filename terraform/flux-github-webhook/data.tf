data "kubernetes_resource" "receiver" {
  api_version = "notification.toolkit.fluxcd.io/v1"
  kind        = "Receiver"

  metadata {
    name      = "github-receiver"
    namespace = "flux-system"
  }

  depends_on = [kubernetes_manifest.receiver]
}

# data "github_repository" "self" {
#   full_name = var.repo
# }
