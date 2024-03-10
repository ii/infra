terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
    }
    flux = {
      source = "fluxcd/flux"
    }
    github = {
      source = "integrations/github"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
