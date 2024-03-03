data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [for k, v in equinix_metal_device.cp : v.network.0.address]
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
  node                 = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.kube_apiserver_domain}:6443"

  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

data "helm_template" "cilium" {
  name        = "cilium"
  namespace   = "kube-system"
  repository  = "https://helm.cilium.io/"
  chart       = "cilium"
  version     = "1.13.1"
  description = "Cilium Bootstrapped via terraform helm_templates injected into talos cluster.inlineManifests"
  skip_tests  = false
  atomic      = true
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
    k8sServiceHost: ${equinix_metal_reserved_ip_block.cluster_virtual_ip.network}
    k8sServicePort: 6443
    EOT
  ]
}
