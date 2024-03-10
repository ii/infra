# NOTE:
# module.sharing-io-manifests.kubernetes_namespace.kube-system: Creating...
#╷
#│ Error: namespaces "kube-system" already exists
#│
#│   with module.sharing-io-manifests.kubernetes_namespace.kube-system,
#│   on terraform/manifests/main.tf line 1, in resource "kubernetes_namespace" "kube-system":
#│    1: resource "kubernetes_namespace" "kube-system" {
#│
# resource "kubernetes_namespace" "kube-system" {
#   metadata {
#     name = "kube-system"
#     labels = {
#       "pod-security.kubernetes.io/enforce" = "privileged"
#     }
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }

resource "kubernetes_config_map_v1" "ingress-ip" {
  metadata {
    name      = "ingressip"
    namespace = "flux-system"
  }

  data = {
    ingressip = var.ingress_ip
  }
  depends_on = [
    kubernetes_namespace.flux-system
  ]
}
