resource "kubernetes_namespace" "powerdns" {
  metadata {
    name = "powerdns"
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
  }
}

resource "random_string" "auth_api_key" {
  length  = 24
  special = false
  lower   = true
  upper   = false
  numeric = false
}
resource "random_string" "gpsql_password" {
  length  = 24
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "kubernetes_secret_v1" "powerdns-config" {
  metadata {
    name      = "powerdns-config"
    namespace = "powerdns"
  }

  data = {
    PDNS_AUTH_API_KEY   = random_string.auth_api_key.result
    PDNS_gpsql_password = random_string.gpsql_password.result
  }
  depends_on = [
    kubernetes_namespace.powerdns
  ]
}

resource "kubernetes_config_map_v1" "powerdns-config" {
  metadata {
    name      = "powerdns-config"
    namespace = "powerdns"
  }

  data = {
    PRIMARY_DOMAIN    = var.domain
    TEMPLATE_FILES    = "_api,gpsql,dnsupdate,soa-content"
    PDNS_gpsql_dnssec = "yes"
    PDNS_gpsql_host   = "pdns-db-postgresql"
    PDNS_gpsql_dbname = "postgres"
    PDNS_SITE_NAME    = "PowerDNS for ${var.domain}"
  }
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
