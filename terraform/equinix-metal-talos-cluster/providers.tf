terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
    helm = {
      source = "hashicorp/helm"
    }
    equinix = {
      source = "equinix/equinix"
    }
    dns = {
      source = "hashicorp/dns"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}
