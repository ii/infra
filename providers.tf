terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    equinix = {
      source  = "equinix/equinix"
      version = "1.13.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.2.3"
    }
    github = {
      source  = "integrations/github"
      version = "6.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    powerdns = {
      source  = "pan-net/powerdns"
      version = "1.5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }
  }
  backend "kubernetes" {
    secret_suffix = "cluster-state"
    namespace     = "hh"
  }
}
provider "talos" {
  alias = "talos"
  # Configuration options
}
provider "helm" {
  alias = "helm"
  # Configuration options
}
provider "equinix" {
  alias = "equinix"
  # Configuration options
  token = var.equinix_metal_auth_token
}
provider "github" {
  owner = var.github_org
  token = var.github_token
}
provider "dns" {
  update {
    server        = var.rfc2136_nameserver
    key_name      = var.rfc2136_tsig_keyname
    key_secret    = var.rfc2136_tsig_key
    key_algorithm = "hmac-sha256"
  }
}
provider "kubernetes" {
  alias = "cluster"
  # config_path = "./tmp/cluster-kubeconfig"
  # config_path = "./tmp/kubeconfig"
  # host                   = "https://${module.cluster.kubeconfig.node}:6443"
  # We use an IP here to speed things up, the first nome name might work as well
  host                   = "https://${module.cluster.cluster_node0_ip}:6443"
  client_certificate     = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.ca_certificate)
}
provider "flux" {
  alias = "cluster"
  kubernetes = {
    # config_path = "./tmp/cluster-kubeconfig"
    # host                   = "https://${module.cluster.kubeconfig.node}:6443"
    # We use an IP here to speed things up, the first nome name might work as well
    host                   = "https://${module.cluster.cluster_node0_ip}:6443"
    client_certificate     = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.ca_certificate)
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = module.cluster-flux-bootstrap.github_repository_deploy_key
    }
  }
}
provider "authentik" {
  url   = "https://sso.${var.domain}"
  token = module.cluster-manifests.authentik_bootstrap_token
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
}
provider "powerdns" {
  api_key    = var.pdns_api_key
  server_url = var.pdns_host
}
