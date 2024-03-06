resource "random_string" "random" {
  count   = var.controlplane_nodes
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "equinix_metal_device" "cp" {
  for_each         = { for idx, val in random_string.random : idx => val }
  hostname         = "${var.cluster_name}-${each.value.result}"
  plan             = var.equinix_metal_plan
  metro            = var.equinix_metal_metro
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = var.equinix_metal_project_id
  ipxe_script_url  = var.ipxe_script_url
  always_pxe       = "false"
}

resource "equinix_metal_bgp_session" "cp_bgp" {
  for_each       = { for idx, val in equinix_metal_device.cp : idx => val }
  device_id      = each.value.id
  address_family = "ipv4"
}

resource "equinix_metal_reserved_ip_block" "cluster_virtual_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1

  tags = ["eip-apiserver-${var.cluster_name}"]
}

resource "equinix_metal_reserved_ip_block" "cluster_ingress_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1

  tags = ["eip-ingress-${var.cluster_name}"]
}

resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

resource "talos_machine_configuration_apply" "cp" {
  for_each                    = { for idx, val in equinix_metal_device.cp : idx => val }
  endpoint                    = each.value.network.0.address
  node                        = each.value.network.0.address
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  config_patches = [
    <<-EOT
    machine:
       kubelet:
         nodeIP:
           validSubnets:
             - ${each.value.network.0.address}/32
         extraArgs:
           cloud-provider: external
       network:
         hostname: ${each.value.hostname}
         interfaces:
           - interface: lo
             addresses:
               - ${equinix_metal_reserved_ip_block.cluster_virtual_ip.network}
           - interface: eth0
             vip:
               ip: ${equinix_metal_reserved_ip_block.cluster_virtual_ip.network}
               equinixMetal:
                 apiToken: ${var.equinix_metal_auth_token}
       install:
         disk: /dev/sda
    EOT
    ,
    <<-EOT
    machine:
       certSANs:
         - ${var.kube_apiserver_domain}
         - ${equinix_metal_reserved_ip_block.cluster_virtual_ip.network}
       kubelet:
         extraArgs:
           cloud-provider: external
       features:
         kubePrism:
           enabled: true
           port: 7445
    cluster:
       allowSchedulingOnMasters: true
       # The rest of this is for cilium
       #  https://www.talos.dev/v1.3/kubernetes-guides/network/deploying-cilium/
       proxy:
         disabled: true
       network:
         cni:
           name: none
       externalCloudProvider:
         enabled: true
         manifests:
           - https://github.com/equinix/cloud-provider-equinix-metal/releases/download/${var.equinix_metal_cloudprovider_controller_version}/deployment.yaml
       controllerManager:
         extraArgs:
           cloud-provider: external
       apiServer:
         extraArgs:
           cloud-provider: external
       apiServer:
         certSANs:
           - ${var.kube_apiserver_domain}
           - ${equinix_metal_reserved_ip_block.cluster_virtual_ip.network}
       inlineManifests:
         - name: cpem-secret
           contents: |
             apiVersion: v1
             stringData:
               cloud-sa.json: |
                 {"apiKey":"${var.equinix_metal_auth_token}","projectID":"${var.equinix_metal_project_id}","metro":"${var.equinix_metal_metro}","eipTag":"eip-apiserver-${var.cluster_name}","eipHealthCheckUseHostIP":true,"loadBalancer":"metallb:///metallb-system?crdConfiguration=true"}
             kind: Secret
             metadata:
               name: metal-cloud-config
               namespace: kube-system
         - name: ns-kube-system-namespace-podsecurity
           contents: |
             apiVersion: v1
             kind: Namespace
             metadata:
               name: kube-system
               labels:
                 pod-security.kubernetes.io/enforce: privileged
         - name: ns-flux-system
           contents: |
             apiVersion: v1
             kind: Namespace
             metadata:
               name: flux-system
    EOT
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
  node                 = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
}
