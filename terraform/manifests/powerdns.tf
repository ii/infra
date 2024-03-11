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
    PDNS_AUTH_API_KEY       = random_string.auth_api_key.result
    PDNS_gpsql_password     = random_string.gpsql_password.result
    SQLALCHEMY_DATABASE_URI = ""
    SECRET_KEY              = random_string.auth_api_key.result
    PDNS_SITE_NAME          = "PowerDNS"
    PDNS_URL                = "https://pdns.${var.domain}"
    PDNS_VERSION            = "4.8.1"
    # TODO correct this value?
    PDNS_ZONES          = <<-EOT
      ${var.domain}
EOT
    PDNS_ADMIN_USER     = ""
    PDNS_ADMIN_PASSWORD = ""
    PDNS_ADMIN_EMAIL    = ""
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
    PRIMARY_DOMAIN            = var.domain
    TEMPLATE_FILES            = "_api,gpsql,dnsupdate,soa-content"
    PDNS_gpsql_dnssec         = "yes"
    PDNS_gpsql_host           = "pdns-db-postgresql"
    PDNS_gpsql_dbname         = "postgres"
    PDNS_SITE_NAME            = "PowerDNS for ${var.domain}"
    SQLALCHEMY_ENGINE_OPTIONS = <<-EOT
                {
                  "echo": "True"
                  "echo_pool": "True"
                }
EOT
  }
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
