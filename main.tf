module "sharing-io" {
  source = "./terraform/equinix-metal-talos-cluster-with-ccm"

  cluster_name             = "sharing-io"
  kube_apiserver_domain    = "k8s.sharing.io"
  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = local.metro
  equinix_metal_auth_token = var.equinix_metal_auth_token
  talos_version            = local.talos_version
  kubernetes_version       = local.kubernetes_version
  ipxe_script_url          = local.ipxe_script_url
  controlplane_nodes       = 3
  acme_email_address       = "acme@ii.coop"
  rfc2136_algorithm        = "HMACSHA256"
  rfc2136_nameserver       = var.rfc2136_nameserver
  rfc2136_server           = var.rfc2136_server
  rfc2136_tsig_keyname     = var.rfc2136_tsig_keyname
  rfc2136_tsig_key         = var.rfc2136_tsig_key
  domain                   = "sharing.io"
  pdns_host                = var.pdns_host
  pdns_api_key             = var.pdns_api_key

  providers = {
    talos   = talos
    helm    = helm
    equinix = equinix
  }
}
module "sharing-io-record-apiserver-ip" {
  source = "./terraform/rfc2136-record-assign"

  zone      = "sharing.io."
  name      = "k8s"
  addresses = [module.sharing-io.cluster_apiserver_ip]

  providers = {
    dns = dns
  }

  depends_on = [module.sharing-io]
}
module "sharing-io-record-ingress-ip" {
  source = "./terraform/rfc2136-record-assign"

  zone      = "sharing.io."
  name      = "*"
  addresses = [module.sharing-io.cluster_ingress_ip]

  providers = {
    dns = dns
  }

  depends_on = [module.sharing-io]
}

# module "sharing-io-metallb" {
#   source       = "./terraform/metallb"
#   ingress_ip   = module.sharing-io.cluster_ingress_ip
#   customer_asn    = module.sharing-io.data.equinix_metal_device_bgp_neighbors.bpg_neighbor
#   customer_ip    = ""
#   peer_as     = ""
#   peer_ips = ""

#   k8s_host               = module.sharing-io.kubeconfig.kubernetes_client_configuration.host
#   k8s_client_certificate = module.sharing-io.kubeconfig.kubernetes_client_configuration.client_certificate
#   k8s_client_key         = module.sharing-io.kubeconfig.kubernetes_client_configuration.client_key
#   k8s_ca_certificate     = module.sharing-io.kubeconfig.kubernetes_client_configuration.ca_certificate

#   providers = {
#     kubernetes = kubernetes
#   }
# }

module "sharing-io-flux-bootstrap" {
  source = "./terraform/flux-bootstrap"

  github_org        = var.github_org
  github_repository = var.github_repository
  cluster_name      = "sharing.io"
  kubeconfig        = module.sharing-io.kubeconfig.kubeconfig_raw

  providers = {
    github = github
  }
}
