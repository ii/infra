terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.1.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    equinix = {
      source  = "equinix/equinix"
      version = "1.13.0"
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
