terraform {
  required_providers {
    kubernetes = {
      source = "integrations/kubernetes"
    }
  }
}

provider "kubernetes" {
  host                   = var.k8s_host
  client_certificate     = var.k8s_client_certificate
  client_key             = var.k8s_client_key
  cluster_ca_certificate = var.cluster_ca_certificate
}
