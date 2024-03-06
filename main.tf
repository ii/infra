module "sharing-io" {
  source = "./terraform/equinix-metal-talos-cluster-with-ccm"

  cluster_name             = "sharing-io"
  kube_apiserver_domain    = "sharingio.sharing.io"
  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = local.metro
  equinix_metal_auth_token = var.equinix_metal_auth_token
  talos_version            = local.talos_version
  kubernetes_version       = local.kubernetes_version
  ipxe_script_url          = local.ipxe_script_url
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
module "sharing-io-record-ingress-ip" {
  source = "./terraform/rfc2136-record-assign"

  zone      = "sharing.io."
  name      = "*"
  addresses = [module.sharing-io.ingress_ip]

  providers = {
    dns = dns
  }

  depends_on = [module.sharing-io]
}
module "sharing-io-flux-bootstrap" {
  source = "./terraform/flux-bootstrap"

  github_org        = var.github_org
  github_repository = var.github_repository
  cluster_name      = "sharing.io"
  kubeconfig        = module.sharing-io.kubeconfig

  providers = {
    github = github
  }
}

