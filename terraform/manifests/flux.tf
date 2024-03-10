resource "kubernetes_namespace" "flux-system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
  }
}

# TODO move outside the manifest module
resource "random_string" "flux_receiver_token" {
  length  = 12
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "kubernetes_secret_v1" "flux_receiver_token" {
  metadata {
    name      = "receiver-token"
    namespace = "flux-system"
  }

  data = {
    token = random_string.flux_receiver_token.result
  }
  depends_on = [
    kubernetes_namespace.flux-system
  ]
}
