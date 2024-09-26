data "kubernetes_secret_v1" "authentik_env" {
  metadata {
    name      = "authentik-env"
    namespace = "authentik"
  }
  depends_on = [kubernetes_secret_v1.authentik_env]
}
data "kubernetes_config_map_v1" "authentik_env" {
  metadata {
    name      = "authentik-env"
    namespace = "authentik"
  }
  depends_on = [kubernetes_config_map.authentik_env]
}

data "kubernetes_config_map_v1" "coder_kustomize" {
  metadata {
    name      = "coder-kustomize"
    namespace = "flux-system"
  }
  depends_on = [kubernetes_config_map.coder_kustomize]
}
data "kubernetes_secret_v1" "coder" {
  metadata {
    name      = "coder-config"
    namespace = "coder"
  }
  depends_on = [kubernetes_secret_v1.coder]
}
data "kubernetes_config_map_v1" "coder_config" {
  metadata {
    name      = "coder-config"
    namespace = "coder"
  }
  depends_on = [kubernetes_config_map.coder_config]
}
