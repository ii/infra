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

resource "equinix_metal_reserved_ip_block" "cluster_apiserver_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1
  tags       = ["eip-apiserver-${var.cluster_name}"]
}

resource "equinix_metal_reserved_ip_block" "cluster_ingress_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1
  tags       = ["eip-ingress-${var.cluster_name}"]
}

resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

# NOTE
#       anonymous-auth is set to true for the APIServer.
#       this must be removed after a future update to the Equinix Metal Cloud Provider controller.

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
               - ${equinix_metal_reserved_ip_block.cluster_apiserver_ip.address}
           - deviceSelector:
               busPath: "0*"
             dhcp: true
             addresses:
               - ${equinix_metal_reserved_ip_block.cluster_ingress_ip.address}
             vip:
               ip: ${equinix_metal_reserved_ip_block.cluster_ingress_ip.address}
               equinixMetal:
                 apiToken: ${var.equinix_metal_auth_token}
             routes:
               - network: ${data.equinix_metal_device_bgp_neighbors.bgp_neighbor[each.key].bgp_neighbors[0].peer_ips[0]}/32
                 gateway: ${[for k in each.value.network : k.gateway if k.public == false && k.family == 4][0]}
               - network: ${data.equinix_metal_device_bgp_neighbors.bgp_neighbor[each.key].bgp_neighbors[0].peer_ips[1]}/32
                 gateway: ${[for k in each.value.network : k.gateway if k.public == false && k.family == 4][0]}
       install:
         disk: /dev/sda
    EOT
    ,
    <<-EOT
    machine:
       certSANs:
         - ${var.kube_apiserver_domain}
         - ${equinix_metal_reserved_ip_block.cluster_apiserver_ip.network}
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
           - ${var.kube_apiserver_domain}
           - ${equinix_metal_reserved_ip_block.cluster_apiserver_ip.network}
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
         - name: ns-cert-manager
           contents: |
             apiVersion: v1
             kind: Namespace
             metadata:
               name: cert-manager
         - name: ingress-ip
           contents: |
             apiVersion: v1
             kind: ConfigMap
             metadata:
               name: ingressip
               namespace: flux-system
             data:
               ingressip: ${equinix_metal_reserved_ip_block.cluster_ingress_ip.network}
         - name: rfc2136dnsserver
           contents: |
             apiVersion: v1
             kind: Secret
             metadata:
               name: rfc2136dnsserver
               namespace: flux-system
             stringData:
               email: ${var.acme_email_address}
               nameserver: ${var.rfc2136_nameserver}
               keyname: ${var.rfc2136_tsig_keyname}
               key: ${var.rfc2136_tsig_key}
               algorithm: ${var.rfc2136_algorithm}
               domain: ${var.domain}
               pdnsapikey: ${var.pdns_api_key}
               pdnshost: ${var.pdns_host}
         - name: cert-manager-rfc2136
           contents: |
             apiVersion: v1
             kind: Secret
             metadata:
               name: rfc2136
               namespace: cert-manager
             stringData:
               key: ${var.rfc2136_tsig_key}
         - name: cert-manager-pdns
           contents: |
             apiVersion: v1
             kind: Secret
             metadata:
               name: pdns
               namespace: cert-manager
             stringData:
               api-key: ${var.pdns_api_key}
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
