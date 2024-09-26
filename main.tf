module "cluster" {
  source = "./terraform/equinix-metal-talos-cluster"

  talos_version             = var.talos_version
  kubernetes_version        = var.kubernetes_version
  kubernetes_apiserver_fqdn = "k8s.${var.domain}"
  controlplane_nodes        = var.kubernetes_control_plane_nodes
  cluster_name              = var.github_org
  domain                    = var.domain
  equinix_metal_project_id  = var.equinix_metal_project_id
  equinix_metal_metro       = var.equinix_metal_metro
  equinix_metal_auth_token  = var.equinix_metal_auth_token
  equinix_metal_plan        = var.equinix_metal_plan
  talos_install_disk        = var.talos_install_disk
  longhorn_disk             = var.longhorn_disk

  providers = {
    talos   = talos
    helm    = helm
    equinix = equinix
    dns     = dns
    http    = http
  }
}
resource "local_sensitive_file" "cluster-kubeconfig" {
  content  = module.cluster.kubeconfig.kubeconfig_raw
  filename = "./tmp/cluster-kubeconfig"

  lifecycle {
    ignore_changes = all
  }
}
module "cluster-manifests" {
  source = "./terraform/manifests"

  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = var.equinix_metal_metro
  equinix_metal_auth_token = var.equinix_metal_auth_token
  ingress_ip               = module.cluster.cluster_ingress_ip
  dns_ip                   = module.cluster.cluster_dns_ip
  wg_ip                    = module.cluster.cluster_wireguard_ip
  acme_email_address       = var.acme_email_address
  rfc2136_nameserver       = var.rfc2136_nameserver
  rfc2136_tsig_keyname     = var.rfc2136_tsig_keyname
  rfc2136_tsig_algorithm   = var.rfc2136_tsig_algorithm
  rfc2136_tsig_key         = var.rfc2136_tsig_key
  domain                   = var.domain
  pdns_host                = var.pdns_host
  pdns_api_key             = var.pdns_api_key
  # for coder to directly authenticate via github
  coder_version                     = var.coder_version
  coder_oauth2_github_client_id     = var.coder_oauth2_github_client_id
  coder_oauth2_github_client_secret = var.coder_oauth2_github_client_secret
  # for coder to create gh tokens for rw within workspaces
  coder_gitauth_0_client_id     = var.coder_gitauth_0_client_id
  coder_gitauth_0_client_secret = var.coder_gitauth_0_client_secret
  providers = {
    kubernetes = kubernetes.cluster
    random     = random
  }
  authentik_version = var.authentik_version
  depends_on        = [local_sensitive_file.cluster-kubeconfig, module.cluster]
}

module "cluster-flux-bootstrap" {
  source = "./terraform/flux-bootstrap"

  github_org        = var.github_org
  github_repository = var.github_repository
  kubeconfig        = module.cluster.kubeconfig.kubeconfig_raw

  providers = {
    github = github
    flux   = flux.cluster
  }
  depends_on = [local_sensitive_file.cluster-kubeconfig, module.cluster-manifests]
}

# module "cluster-flux-github-webhook" {
#   source = "./terraform/flux-github-webhook"

#   repo = var.github_repository
#   # repo   = "${var.github_org}/${var.github_repository}"
#   domain = var.domain
#   secret = module.cluster-manifests.flux_receiver_token

#   providers = {
#     github     = github
#     kubernetes = kubernetes.cluster
#   }

#   depends_on = [local_sensitive_file.cluster-kubeconfig, module.cluster-manifests, module.cluster-flux-bootstrap]
# }

