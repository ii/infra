
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "FluxCD::${var.cluster}"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"

  lifecycle {
    ignore_changes = all
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [
    github_repository_deploy_key.this
  ]
  path             = "clusters/${var.cluster}"
  components_extra = ["image-reflector-controller", "image-automation-controller"]
}
