data "helm_template" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.13.1"
  description      = "Cilium Bootstrapped via terraform helm_templates injected into talos cluster.inlineManifests"
  create_namespace = true
  skip_tests       = false
  atomic           = true
  values = [
    <<-EOT
    ipam:
      mode: kubernetes
    kubeProxyReplacement: strict
    securityContext:
      capabilities:
        ciliumAgent:
          - CHOWN
          - KILL
          - NET_ADMIN
          - NET_RAW
          - IPC_LOCK
          - SYS_ADMIN
          - SYS_RESOURCE
          - DAC_OVERRIDE
          - FOWNER
          - SETGID
          - SETUID
        cleanCiliumState:
          - NET_ADMIN
          - SYS_ADMIN
          - SYS_RESOURCE
    cgroup:
      autoMount:
        enabled: false
      hostRoot: /sys/fs/cgroup
    k8sServiceHost: 145.40.90.158
    k8sServicePort: 6443
    EOT
  ]
}
