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
  # to use: export METAL_AUTH_TOKEN
}
provider "dns" {
  update {
    server        = var.rfc2136_server
    key_name      = var.rfc2136_tsig_keyname
    key_secret    = var.rfc2136_tsig_key
    key_algorithm = "hmac-sha256"
  }
}
