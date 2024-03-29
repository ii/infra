module "sharing-io" {
  source = "./terraform/equinix-metal-talos-cluster"

  cluster_name             = "sharing-io"
  kube_apiserver_domain    = "k8s.sharing.io"
  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = local.metro
  equinix_metal_auth_token = var.equinix_metal_auth_token
  talos_version            = local.talos_version
  kubernetes_version       = local.kubernetes_version
  ipxe_script_url          = local.ipxe_script_url
  controlplane_nodes       = 3
  talos_install_image      = local.talos_install_image

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
module "sharing-io-record-dns-ip" {
  source = "./terraform/rfc2136-record-assign"

  zone      = "sharing.io."
  name      = "dns"
  addresses = [module.sharing-io.cluster_dns_ip]

  providers = {
    dns = dns
  }

  depends_on = [module.sharing-io]
}
resource "powerdns_zone" "try" {
  name        = "try.sharing.io."
  kind        = "Native"
  nameservers = ["ns1.sharing.io.", "ns2.sharing.io."]
}
resource "powerdns_record" "try-A" {
  zone       = "try.sharing.io."
  name       = "try.sharing.io."
  type       = "A"
  ttl        = 300
  records    = [module.sharing-io.cluster_ingress_ip]
  depends_on = [powerdns_zone.try]
}
resource "powerdns_record" "try-WILDCARD" {
  zone       = "try.sharing.io."
  name       = "*.try.sharing.io."
  type       = "A"
  ttl        = 300
  records    = [module.sharing-io.cluster_ingress_ip]
  depends_on = [powerdns_zone.try]
}
resource "powerdns_record" "wg-A" {
  # TUNNELD_WIREGUARD_ENDPOINT
  zone       = "sharing.io."
  name       = "wg.sharing.io."
  type       = "A"
  ttl        = 300
  records    = [module.sharing-io.cluster_wireguard_ip]
  depends_on = [powerdns_zone.try]
}
resource "powerdns_zone" "coder" {
  name        = "coder.sharing.io."
  kind        = "Native"
  nameservers = ["ns1.sharing.io.", "ns2.sharing.io."]
}
resource "powerdns_record" "coder-A" {
  zone       = "coder.sharing.io."
  name       = "coder.sharing.io."
  type       = "A"
  ttl        = 300
  records    = [module.sharing-io.cluster_ingress_ip]
  depends_on = [powerdns_zone.coder]
}
resource "powerdns_record" "coder-WILDCARD" {
  zone       = "coder.sharing.io."
  name       = "*.coder.sharing.io."
  type       = "A"
  ttl        = 300
  records    = [module.sharing-io.cluster_ingress_ip]
  depends_on = [powerdns_zone.coder]
}
module "sharing-io-record-wireguard-ip" {
  source = "./terraform/rfc2136-record-assign"

  zone      = "sharing.io."
  name      = "wireguard"
  addresses = [module.sharing-io.cluster_wireguard_ip]

  providers = {
    dns = dns
  }

  depends_on = [module.sharing-io]
}
resource "local_sensitive_file" "sharingio-kubeconfig" {
  content  = module.sharing-io.kubeconfig.kubeconfig_raw
  filename = "./tmp/sharing-io-kubeconfig"

  lifecycle {
    ignore_changes = all
  }
}
module "sharing-io-manifests" {
  source = "./terraform/manifests"

  equinix_metal_project_id = var.equinix_metal_project_id
  equinix_metal_metro      = local.metro
  equinix_metal_auth_token = var.equinix_metal_auth_token
  ingress_ip               = module.sharing-io.cluster_ingress_ip
  dns_ip                   = module.sharing-io.cluster_dns_ip
  wg_ip                    = module.sharing-io.cluster_wireguard_ip
  acme_email_address       = "acme@ii.coop"
  rfc2136_algorithm        = "HMACSHA256"
  rfc2136_nameserver       = var.rfc2136_nameserver
  rfc2136_tsig_keyname     = var.rfc2136_tsig_keyname
  rfc2136_tsig_key         = var.rfc2136_tsig_key
  domain                   = "sharing.io"
  pdns_host                = var.pdns_host
  pdns_api_key             = var.pdns_api_key
  # for coder to directly authenticate via github
  coder_oauth2_github_client_id     = var.coder_oauth2_github_client_id
  coder_oauth2_github_client_secret = var.coder_oauth2_github_client_secret
  # for coder to create gh tokens for rw within workspaces
  coder_gitauth_0_client_id     = var.coder_gitauth_0_client_id
  coder_gitauth_0_client_secret = var.coder_gitauth_0_client_secret
  providers = {
    kubernetes = kubernetes.sharing-io
    random     = random
  }
  depends_on = [local_sensitive_file.sharingio-kubeconfig, module.sharing-io]
}

module "sharing-io-flux-bootstrap" {
  source = "./terraform/flux-bootstrap"

  github_org        = var.github_org
  github_repository = var.github_repository
  cluster_name      = "sharing.io"
  kubeconfig        = module.sharing-io.kubeconfig.kubeconfig_raw

  providers = {
    github = github
    flux   = flux.sharing-io
  }
  depends_on = [local_sensitive_file.sharingio-kubeconfig, module.sharing-io-manifests]
}

module "sharing-io-flux-github-webhook" {
  source = "./terraform/flux-github-webhook"

  repo = var.github_repository
  # repo   = "${var.github_org}/${var.github_repository}"
  domain = "sharing.io"
  secret = module.sharing-io-manifests.flux_receiver_token

  providers = {
    github     = github
    kubernetes = kubernetes.sharing-io
  }

  depends_on = [module.sharing-io-manifests]
}

# module "sharing-io-authentik-config" {
#   source                             = "./terraform/authentik-config"
#   github_oauth_app_id                = var.authentik_github_oauth_app_id
#   github_oauth_app_secret            = var.authentik_github_oauth_app_secret
#   authentik_coder_oidc_client_id     = module.sharing-io-manifests.authentik_coder_oidc_client_id
#   authentik_coder_oidc_client_secret = module.sharing-io-manifests.authentik_coder_oidc_client_secret
#   authentik_bootstrap_token          = module.sharing-io-manifests.authentik_bootstrap_token
#   # repo = var.github_repository
#   # # repo   = "${var.github_org}/${var.github_repository}"
#   # domain = "sharing.io"
#   # secret = module.sharing-io-manifests.flux_receiver_token

#   providers = {
#     authentik  = authentik
#     flux       = flux
#     kubernetes = kubernetes.sharing-io
#   }

#   depends_on = [module.sharing-io-manifests]
# }
