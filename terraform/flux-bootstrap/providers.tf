terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
    }
    github = {
      source = "integrations/github"
    }
  }
}

provider "flux" {
  kubernetes = {
    # host                   = module.kubeconfig.host
    # client_certificate     = module.kubeconfig.client_certificate
    # client_key             = module.kubeconfig.client_key
    # cluster_ca_certificate = module.kubeconfig.cluster_ca_certificate
    config_path = "./tmp/${var.cluster_name}-kubeconfig"
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}
