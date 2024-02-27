resource "equinix_metal_device" "cp" {
  count            = var.controlplane_nodes
  hostname         = "${var.cluster_name}-${count.index + 1}"
  plan             = "c3.medium.x86"
  metro            = "sv"
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = var.equinix_metal_project_id
  ipxe_script_url  = "https://pxe.factory.talos.dev/pxe/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.6.5/metal-amd64"
  always_pxe       = "false"
}

resource "talos_machine_secrets" "machine_secrets" {}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  for_each              = { for idx, val in equinix_metal_device.cp : idx => val }
  endpoint              = each.value.network.0.address
  node                  = each.value.network.0.address
  talos_config          = talos_client_configuration.talosconfig.talos_config
  machine_configuration = talos_machine_configuration_controlplane.machineconfig_cp.machine_config
  config_patches = [
    <<-EOT
    machine:
       kubelet:
         extraArgs:
           cloud-provider: external
       network:
         hostname: ${each.value.hostname}
         interfaces:
           - interface: eth0
             dhcp: true
             vip:
               ip: ${var.virtual_ip}
       install:
         disk: /dev/sda
    EOT
  ]
}

resource "talos_machine_configuration_controlplane" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  docs_enabled     = false
  examples_enabled = false
  config_patches = [
    <<-EOT
    machine:
       network:
         interfaces:
           - interface: eth0
             dhcp: true
             vip:
               ip: ${var.virtual_ip}
       install:
         disk: /dev/sda
    EOT
    ,
    <<-EOT
    machine:
       certSANs:
         - k8s.cloudnative.coop
         - ${var.virtual_ip}
       kubelet:
         extraArgs:
           cloud-provider: external
    cluster:
       allowSchedulingOnMasters: true
       # The rest of this is for cilium
       #  https://www.talos.dev/v1.3/kubernetes-guides/network/deploying-cilium/
       proxy:
         disabled: true
       network:
         cni:
           name: none
       controllerManager:
         extraArgs:
           cloud-provider: external
       apiServer:
         extraArgs:
           cloud-provider: external
         certSANs:
           - k8s.cloudnative.coop
           - ${var.virtual_ip}
       # Going to try and add this via patch so we can inline the rendered cilium helm template
       inlineManifests:
         - name: cilium
    EOT
    ,
    yamlencode([
      {
        "op" : "replace",
        "path" : "/cluster/inlineManifests/0/contents",
        "value" : data.helm_template.cilium.manifest
      }
    ])
  ]
}

resource "talos_client_configuration" "talosconfig" {
  cluster_name    = var.cluster_name
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets
  endpoints       = [for k, v in equinix_metal_device.cp : v.network.0.address]
}

resource "talos_machine_bootstrap" "bootstrap" {
  talos_config = talos_client_configuration.talosconfig.talos_config
  endpoint     = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
  node         = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  talos_config = talos_client_configuration.talosconfig.talos_config
  endpoint     = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
  node         = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
}

