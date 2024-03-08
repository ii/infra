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

resource "kubernetes_secret_v1" "metal-cloud-config" {
  metadata {
    name      = "metal-cloud-config"
    namespace = "kube-system"
  }

  data = {
    "cloud-sa.json" = jsonencode({
      // TODO make variables and pass through
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
    // TODO create var and pass value through
    ingressip = var.ingress_ip
  }
}

resource "kubernetes_secret_v1" "rfc2136-dns-server" {
  metadata {
    name      = "rfc2136dnsserver"
    namespace = "flux-system"
  }

  data = {
    // TODO create vars and pass throuhg values
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
    // TODO create vars and pass throuhg values
    key = var.rfc2136_tsig_key
  }
}

resource "kubernetes_secret_v1" "pdns-cert-manager" {
  metadata {
    name      = "pdns"
    namespace = "cert-manager"
  }

  data = {
    // TODO create vars and pass throuhg values
    api-key = var.pdns_api_key
  }
}
