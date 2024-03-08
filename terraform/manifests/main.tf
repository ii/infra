resource "kubernetes_namespace" "kube-system" {
  metadata {
    name = "kube-system"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_namespace" "flux-system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
  }
}

resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
  }
}

resource "kubernetes_secret_v1" "metal-cloud-config" {
  metadata {
    name      = "metal-cloud-config"
    namespace = "kube-system"
  }

  data = {
    "cloud-sa.json" = jsonencode({
      apiKey                  = var.equinix_metal_auth_token
      projectID               = var.equinix_metal_project_id
      metro                   = var.equinix_metal_metro
      eipTag                  = "eip-apiserver-${var.cluster_name}"
      eipHealthCheckUseHostIP = true
      loadBalancer            = "metallb:///metallb-system?crdConfiguration=true"
    })
  }
}

resource "kubernetes_config_map_v1" "ingress-ip" {
  metadata {
    name      = "ingressip"
    namespace = "flux-system"
  }

  data = {
    ingressip = var.ingress_ip
  }
}

resource "kubernetes_secret_v1" "rfc2136-dns-server" {
  metadata {
    name      = "rfc2136dnsserver"
    namespace = "flux-system"
  }

  data = {
    email      = var.acme_email_address
    nameserver = var.rfc2136_nameserver
    keyname    = var.rfc2136_tsig_keyname
    key        = var.rfc2136_tsig_key
    algorithm  = var.rfc2136_algorithm
    domain     = var.domain
    pdnsapikey = var.pdns_api_key
    pdnshost   = var.pdns_host
  }
}

resource "kubernetes_secret_v1" "rfc2136-cert-manager" {
  metadata {
    name      = "rfc2136"
    namespace = "cert-manager"
  }

  data = {
    key = var.rfc2136_tsig_key
  }
}

resource "kubernetes_secret_v1" "pdns-cert-manager" {
  metadata {
    name      = "pdns"
    namespace = "cert-manager"
  }

  data = {
    api-key = var.pdns_api_key
  }
}

# TODO move outside the manifest module
resource "random_string" "flux_receiver_token" {
  length  = 12
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "kubernetes_secret_v1" "flux_receiver_token" {
  metadata {
    name      = "receiver-token"
    namespace = "flux-system"
  }

  data = {
    token = random_string.flux_receiver_token.result
  }
}

# TODO move outside the manifest module
resource "random_string" "authentik_bootstrap_password" {
  length  = 16
  special = false
  lower   = true
  upper   = false
  numeric = false
}
# TODO move outside the manifest module
resource "random_string" "authentik_bootstrap_token" {
  length  = 16
  special = false
  lower   = true
  upper   = false
  numeric = false
}
# TODO move outside the manifest module
resource "random_string" "authentik_secret_key" {
  length  = 50
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "kubernetes_secret_v1" "authentik_env" {
  metadata {
    name      = "authentik-env"
    namespace = "authentik"
  }

  data = {
    AUTHENTIK_BOOTSTRAP_PASSWORD = random_string.authentik_bootstrap_password.result
    AUTHENTIK_BOOTSTRAP_TOKEN    = random_string.authentik_bootstrap_token.result
    AUTHENTIK_SECRET_KEY         = random_string.authentik_secret_key.result
  }
}
