locals {
  talos_schematic      = jsondecode(data.http.talos_schematic.response_body).id
  talos_latest_version = element(jsondecode(data.http.talos_versions.response_body), length(jsondecode(data.http.talos_versions.response_body)) - 1)
  ipxe_script_url      = "https://pxe.factory.talos.dev/pxe/${local.talos_schematic}/${var.talos_version}/equinixMetal-amd64"
  talos_install_image  = "factory.talos.dev/installer/${local.talos_schematic}:${var.talos_version}"
  # ipxe_script_url      = "https://pxe.factory.talos.dev/pxe/${local.talos_schematic}/${talos_latest_version}/equinixMetal-amd64"
  # talos_install_image  = "factory.talos.dev/installer/${local.talos_schematic}:${local.talos_latest_version}"
}


# https://github.com/siderolabs/image-factory?tab=readme-ov-file#get-versions

data "http" "talos_versions" {
  url = "https://factory.talos.dev/versions"
  request_headers = {
    Accept = "application/json"
  }
}

# https://github.com/siderolabs/image-factory?tab=readme-ov-file#http-frontend-api

data "http" "talos_schematic" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"
  request_headers = {
    Accept       = "application/json"
    Content-type = "text/x-yaml"
  }
  request_body = <<-EOT
    customization:
        systemExtensions:
            officialExtensions:
                - siderolabs/gvisor
                - siderolabs/iscsi-tools
                - siderolabs/mdadm
   EOT
}
resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

# NOTE
#       anonymous-auth is set to true for the APIServer.
#       this must be removed after a future update to the Equinix Metal Cloud Provider controller.

resource "talos_machine_configuration_apply" "cp" {
  for_each                    = { for idx, val in equinix_metal_device.cp : idx => val }
  endpoint                    = each.value.hostname
  node                        = each.value.hostname
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  depends_on                  = [equinix_metal_device.cp, equinix_metal_bgp_session.cp_bgp]
  config_patches = [
    <<-EOT
    machine:
       disks:
         - device: ${var.longhorn_disk}
           partitions:
             - mountpoint: /var/lib/longhorn
       kubelet:
         extraMounts:
           - destination: /var/lib/longhorn
             type: bind
             source: /var/lib/longhorn
             options:
             - bind
             - rshared
             - rw
         nodeIP:
           validSubnets:
             - ${each.value.network.0.address}/32
         extraArgs:
           cloud-provider: external
       install:
         disk: ${var.talos_install_disk}
         extraKernelArgs:
            - console=ttyS1,115200n8
            - talos.platform=equinixMetal
         wipe: false
         image: ${local.talos_install_image}
       network:
         hostname: ${each.value.hostname}
         # defaults to false, causes issues when using wildcard DNS
         disableSearchDomain: true
         interfaces:
           - interface: lo
             addresses:
               - ${equinix_metal_reserved_ip_block.cluster_apiserver_ip.address}
           - interface: bond0
             dhcp: true
             vip:
               ip: ${equinix_metal_reserved_ip_block.cluster_ingress_ip.address}
               equinixMetal:
                 apiToken: ${var.equinix_metal_auth_token}
    EOT
    ,
    <<-EOT
    machine:
       certSANs:
         - ${var.kubernetes_apiserver_fqdn}
         - ${equinix_metal_reserved_ip_block.cluster_apiserver_ip.network}
       kubelet:
         registerWithFQDN: true
         extraArgs:
           cloud-provider: external
       features:
         kubePrism:
           enabled: true
           port: 7445
       sysctls:
         user.max_user_namespaces: "11255"
    cluster:
       allowSchedulingOnMasters: true
       #  https://www.talos.dev/v1.3/kubernetes-guides/network/deploying-cilium/
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
           anonymous-auth: true
         certSANs:
           - ${var.kubernetes_apiserver_fqdn}
           - ${equinix_metal_reserved_ip_block.cluster_apiserver_ip.network}
       inlineManifests:
         - name: metal-cloud-config
           contents: |
             apiVersion: v1
             stringData:
               cloud-sa.json: |
                 {"apiKey":"${var.equinix_metal_auth_token}","projectID":"${var.equinix_metal_project_id}","metro":"${var.equinix_metal_metro}","eipTag":"eip-apiserver-${var.cluster_name}","eipHealthCheckUseHostIP":true,"loadBalancer":"metallb:///metallb-system?crdConfiguration=true"}
             kind: Secret
             metadata:
               name: metal-cloud-config
               namespace: kube-system
         - name: kube-system-namespace-podsecurity
           contents: |
             apiVersion: v1
             kind: Namespace
             metadata:
               name: kube-system
               labels:
                 pod-security.kubernetes.io/enforce: privileged
         - name: cilium
     EOT
    ,
    yamlencode([
      {
        "op" : "replace",
        "path" : "/cluster/inlineManifests/2/contents",
        "value" : data.helm_template.cilium.manifest
      }
    ])
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = [for k, v in equinix_metal_device.cp : v.hostname][0]
  node                 = [for k, v in equinix_metal_device.cp : v.hostname][0]
}


data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [[for k, v in equinix_metal_device.cp : v.hostname][0]]
  nodes                = [[for k, v in equinix_metal_device.cp : split(".", v.hostname)[0]][0]]
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
  cluster_endpoint = "https://${var.kubernetes_apiserver_fqdn}:6443"

  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}
