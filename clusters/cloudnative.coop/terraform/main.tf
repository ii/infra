resource "equinix_metal_device" "cp" {
  count            = var.controlplane_nodes
  hostname         = "${var.cluster_name}-${count.index + 1}"
  plan             = var.plan
  metro            = "sv"
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = var.equinix_metal_project_id
  ipxe_script_url  = var.ipxe_script_url
  always_pxe       = "false"
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
    ,
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

resource "talos_machine_bootstrap" "bootstrap" {
  count = var.controlplane_nodes
  depends_on = [
    talos_machine_configuration_apply.cp
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
  node                 = [for k, v in equinix_metal_device.cp : v.network.0.address][0]
}
