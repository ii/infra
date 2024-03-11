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
    SECRET_KEY          = random_string.auth_api_key.result
    PDNS_ADMIN_PASSWORD = ""
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
    PRIMARY_DOMAIN          = var.domain
    TEMPLATE_FILES          = "_api,gpsql,dnsupdate,soa-content"
    PDNS_gpsql_dnssec       = "yes"
    PDNS_gpsql_host         = "pdns-db-postgresql"
    PDNS_gpsql_dbname       = "postgres"
    PDNS_SITE_NAME          = "PowerDNS for ${var.domain}"
    SQLALCHEMY_DATABASE_URI = "sqlite:////data/powerdns-admin.db"
    # https://docs.sqlalchemy.org/en/20/core/engines.html
    # echo{_pool} can also be debug
    # https://docs.sqlalchemy.org/en/20/core/engines.html#sqlalchemy.create_engine.params.execution_options
    # https://docs.sqlalchemy.org/en/20/core/connections.html#sqlalchemy.engine.Connection.execution_options
    SQLALCHEMY_ENGINE_OPTIONS = <<-EOT
      {
        "echo": "True"
        "echo_pool": "True"
      }
    EOT
    PDNS_ADMIN_USER           = ""
    PDNS_ADMIN_EMAIL          = ""
    PDNS_SITE_NAME            = "PowerDNS"
    PDNS_URL                  = "http://auth-web:8081"
    PDNS_VERSION              = "4.8.1"
    # TODO correct this value?
    PDNS_ZONES = <<-EOT
      ${var.domain}
    EOT
  }
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}

resource "kubernetes_config_map_v1" "powerdns-config" {
  metadata {
    name      = "powerdns-config"
    namespace = "powerdns"
  }

  data = {
    PRIMARY_DOMAIN          = var.domain
    TEMPLATE_FILES          = "_api,gpsql,dnsupdate,soa-content"
    PDNS_gpsql_dnssec       = "yes"
    PDNS_gpsql_host         = "pdns-db-postgresql"
    PDNS_gpsql_dbname       = "postgres"
    PDNS_SITE_NAME          = "PowerDNS for ${var.domain}"
    SQLALCHEMY_DATABASE_URI = "sqlite:////data/powerdns-admin.db"
    # https://docs.sqlalchemy.org/en/20/core/engines.html
    # echo{_pool} can also be debug
    # https://docs.sqlalchemy.org/en/20/core/engines.html#sqlalchemy.create_engine.params.execution_options
    # https://docs.sqlalchemy.org/en/20/core/connections.html#sqlalchemy.engine.Connection.execution_options
    SQLALCHEMY_ENGINE_OPTIONS = <<-EOT
      {
        "echo": "True"
        "echo_pool": "True"
      }
    EOT
    PDNS_ADMIN_USER           = ""
    PDNS_ADMIN_EMAIL          = ""
    PDNS_SITE_NAME            = "PowerDNS"
    PDNS_URL                  = "http://auth-web:8081"
    PDNS_VERSION              = "4.8.1"
    # TODO correct this value?
    PDNS_ZONES = <<-EOT
      ${var.domain}
    EOT
  }
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
resource "kubernetes_config_map_v1" "powerdns-kustomize" {
  metadata {
    name      = "powerdns-kustomize"
    namespace = "powerdns"
  }

  data = {
    DNS_IP             = var.dns_ip
    PDNS_API_INGRESS   = "dns.${var.domain}"
    PDNS_ADMIN_INGRESS = "powerdns.${var.domain}"
  }
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
