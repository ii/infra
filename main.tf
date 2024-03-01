module "cloudnative-coop" {
  source = "./terraform/equinix-metal-talos-cluster"

  cluster_name             = "cloudnative-coop"
  kube_apiserver_domain    = "k8s.sharing.io"
  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = "sv"
  equinix_metal_auth_token = var.equinix_metal_auth_token
  talos_version            = "v1.6.5"
  kubernetes_version       = "v1.29.2"
  ipxe_script_url          = "https://pxe.factory.talos.dev/pxe/3c34c887de9c7013d7b382f3796d7465d7a5f54b2757e1a50d663ed7a303385d/v1.6.5/metal-amd64"
  controlplane_nodes       = 3

  providers = {
    talos   = talos
    helm    = helm
    equinix = equinix
  }
}

module "sharing-io" {
  source = "./terraform/equinix-metal-talos-cluster"

  cluster_name             = "sharing-io"
  kube_apiserver_domain    = "sharingio.sharing.io"
  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = "sv"
  equinix_metal_auth_token = var.equinix_metal_auth_token
  talos_version            = "v1.6.5"
  kubernetes_version       = "v1.29.2"
  ipxe_script_url          = "https://pxe.factory.talos.dev/pxe/3c34c887de9c7013d7b382f3796d7465d7a5f54b2757e1a50d663ed7a303385d/v1.6.5/metal-amd64"
  controlplane_nodes       = 3

  providers = {
    talos   = talos
    helm    = helm
    equinix = equinix
  }
}
module "sharing-io-record" {
  source = "./terraform/rfc2136-record-assign"

  zone      = "sharing.io."
  name      = "sharingio"
  addresses = [module.sharing-io.cluster_virtual_ip]

  providers = {
    dns = dns
  }

  depends_on = [module.sharing-io]
}
