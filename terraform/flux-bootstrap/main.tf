resource "local_sensitive_file" "kubeconfig" {
  content  = var.kubeconfig
  filename = "./tmp/${var.cluster_name}-kubeconfig"

  lifecycle {
    ignore_changes = all
  }
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "FluxCD::${var.cluster_name}"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"

  lifecycle {
    ignore_changes = all
  }

  depends_on = [local_sensitive_file.kubeconfig, tls_private_key.flux]
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  path             = "clusters/${var.cluster_name}"
  components_extra = ["image-reflector-controller", "image-automation-controller"]
}
