resource "github_repository_webhook" "flux_webhook" {
  repository = var.repo

  configuration {
    url          = "https://flux-webhook.${var.domain}${data.kubernetes_resource.receiver.object.status.webhookPath}"
    content_type = "application/x-www-form-urlencoded"
    insecure_ssl = false
    secret       = var.secret
  }

  active = true

  events = ["push", "ping"]
}

resource "kubernetes_manifest" "receiver" {
  manifest = {
    "apiVersion" = "notification.toolkit.fluxcd.io/v1"
    "kind"       = "Receiver"
    "metadata" = {
      "name"      = "github-receiver"
      "namespace" = "flux-system"
    }
    "spec" = {
      "events" = [
        "ping",
        "push",
      ]
      "resources" = [
        {
          "apiVersion" = "source.toolkit.fluxcd.io/v1"
          "kind"       = "GitRepository"
          "name"       = "flux-system"
        },
      ]
      "secretRef" = {
        "name" = "receiver-token"
      }
      "type" = "github"
    }
  }
}
