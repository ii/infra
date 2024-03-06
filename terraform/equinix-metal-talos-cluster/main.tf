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

resource "equinix_metal_reserved_ip_block" "cluster_virtual_ip" {
  project_id = var.equinix_metal_project_id
  type       = "public_ipv4"
  metro      = var.equinix_metal_metro
  quantity   = 1

  tags = ["eip-apiserver-${var.cluster_name}"]
}

# NOTE CCM must manage this. This is an unstable/unreliable hack
resource "equinix_metal_ip_attachment" "assign_first_cp_node" {
  device_id     = { for idx, val in equinix_metal_device.cp : idx => val }[0].id
  cidr_notation = join("/", [cidrhost(equinix_metal_reserved_ip_block.cluster_virtual_ip.cidr_notation, 0), "32"])
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
       features:
         kubePrism:
           enabled: true
           port: 7445
    cluster:
       allowSchedulingOnMasters: true
       externalCloudProvider:
         enabled: true
         certSANs:
           - ${var.kube_apiserver_domain}
           - ${equinix_metal_reserved_ip_block.cluster_virtual_ip.network}
       inlineManifests:
         - name: kube-system-namespace-podsecurity
           contents: |
             apiVersion: v1
             kind: Namespace
             metadata:
               name: kube-system
               labels:
                 pod-security.kubernetes.io/enforce: privileged
         - name: ingress-ip
           contents: |
             apiVersion: v1
             kind: ConfigMap
             metadata:
               name: ingress-ip
               namespace: kube-system
             data:
               ingress-ip: ${ { for idx, val in equinix_metal_device.cp : idx => val }[0].network.0.address} }
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
