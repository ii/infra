resource "kubernetes_namespace" "coder" {
  metadata {
    name = "coder"
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
  }
}

# TODO move outside the manifest module
resource "random_string" "coder_postgresql_password" {
  length  = 16
  special = false
  lower   = true
  upper   = false
  numeric = false
}

# TODO move outside the manifest module
resource "random_string" "coder_first_user_password" {
  length  = 16
  special = false
  lower   = true
  upper   = false
  numeric = false
}
# http://man.openbsd.org/wg#Keys
# Keys can be generated with openssl(1) as follows:
# $ openssl rand -base64 32
resource "random_bytes" "tunneld_key" {
  length = 32
}

resource "kubernetes_config_map" "coder_kustomize" {
  metadata {
    name      = "coder-kustomize"
    namespace = "flux-system"
  }

  data = {
    CODER_HOST              = "coder.${var.domain}"
    CODER_ACCESS_URL        = "https://coder.${var.domain}"
    CODER_WILDCARD_DOMAIN   = "coder.${var.domain}"
    CODER_VERSION           = var.coder_version
    TUNNELD_WILDCARD_DOMAIN = "try.${var.domain}"
    wg_ip                   = var.wg_ip
  }
  depends_on = [
    kubernetes_namespace.flux-system
  ]
}

resource "kubernetes_secret_v1" "coder" {
  metadata {
    name      = "coder-config"
    namespace = "coder"
  }

  data = {
    password                          = random_string.coder_postgresql_password.result
    postgres-password                 = random_string.coder_postgresql_password.result
    CODER_PG_CONNECTION_URL           = "postgres://postgres:${random_string.coder_postgresql_password.result}@coder-db-postgresql.coder.svc.cluster.local:5432/coder?sslmode=disable"
    TUNNELD_WIREGUARD_KEY             = random_bytes.tunneld_key.base64
    PDNS_TSIG_KEY                     = var.rfc2136_tsig_key
    PDNS_API_KEY                      = var.pdns_api_key
    CODER_FIRST_USER_PASSWORD         = random_string.coder_first_user_password.result
    CODER_OIDC_CLIENT_ID              = random_password.authentik_coder_oidc_client_id.result
    CODER_OIDC_CLIENT_SECRET          = random_password.authentik_coder_oidc_client_secret.result
    METAL_AUTH_TOKEN                  = var.equinix_metal_auth_token
    TF_VAR_metal_project              = var.equinix_metal_project_id
    CODER_OAUTH2_GITHUB_CLIENT_ID     = var.coder_oauth2_github_client_id
    CODER_OAUTH2_GITHUB_CLIENT_SECRET = var.coder_oauth2_github_client_secret
    CODER_GITAUTH_0_CLIENT_ID         = var.coder_gitauth_0_client_id
    CODER_GITAUTH_0_CLIENT_SECRET     = var.coder_gitauth_0_client_secret
    # "${TUNNELD_WIREGAURD_HOST=tunneld.sharing.io}:54321"
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
}

resource "kubernetes_config_map" "coder_config" {
  metadata {
    name      = "coder-config"
    namespace = "coder"
  }

  data = {
    CODER_HOST                       = "coder.${var.domain}"
    CODER_ACCESS_URL                 = "https://coder.${var.domain}"
    TUNNEL_ACCESS_URL                = "https://try.${var.domain}"
    TUNNEL_WILDCARD_DOMAIN           = "try.${var.domain}"
    CODER_SSH_KEYGEN_ALGORITHM       = "ed25519"
    CODER_PROVISIONER_DAEMONS        = "50"
    CODER_FIRST_USER_USERNAME        = "coder"
    CODER_FIRST_USER_EMAIL           = "coder@ii.coop"
    CODER_FIRST_USER_TRIAIL          = "true"
    CODER_ACCESS_URL                 = "https://coder.${var.domain}"
    CODER_WILDCARD_DOMAIN            = "coder.${var.domain}"
    CODER_WILDCARD_ACCESS_URL        = "*.coder.${var.domain}"
    CODER_SWAGGER_ENABLE             = "true"
    CODER_TELEMETRY                  = "false"
    CODER_GITAUTH_0_ID               = "github"
    CODER_GITAUTH_0_TYPE             = "github"
    CODER_GITAUTH_0_SCOPES           = "repo" # write:gpg_key"
    CODER_OIDC_ICON_URL              = "https://goauthentik.io/img/icon.png"
    CODER_OIDC_GROUP_AUTO_CREATE     = "true"
    CODER_OIDC_ALLOW_SIGNUPS         = "true"
    CODER_OIDC_USERNAME_FIELD        = "preferred_username"
    CODER_OIDC_EMAIL_FIELD           = "email"
    CODER_OIDC_GROUP_FIELD           = "groups" #  https://coder.com/docs/v2/latest/admin/auth#group-sync-enterprise
    CODER_OIDC_GROUP_MAPPING         = <<-EOT
           {"authentik Admins": "CoderAdmins"}
           EOT
    CODER_OIDC_IGNORE_EMAIL_VERIFIED = "true"
    CODER_OIDC_IGNORE_USERINFO       = "false"
    CODER_OIDC_ISSUER_URL            = "https://sso.${var.domain}/application/o/coder/"
    CODER_OIDC_GROUP_REGEX_FILTER    = "^Coder.*$"
    CODER_OIDC_SCOPES                = "openid,profile,email,groups"
    CODER_OIDC_SIGN_IN_TEXT          = "LOGIN"
    CODER_OIDC_ROLE_FIELD            = "groups" #  https://coder.com/docs/v2/latest/admin/auth#group-sync-enterprise
    CODER_OIDC_USER_ROLE_MAPPING     = <<-EOT
            {"authentik Admins": ["owner"]}
            EOT
    # CODER_OAUTH2_GITHUB_ALLOW_EVERYONE = "true"
    CODER_OAUTH2_GITHUB_ALLOWED_ORGS  = "ii,coder,kubermatic"
    CODER_OAUTH2_GITHUB_ALLOW_SIGNUPS = "true"
    # CODER_DISABLE_PASSWORD_AUTH  = "true"
    CODER_BLOCK_DIRECT = "false"
    CODER_BROWSER_ONLY = "false"
    # GITHUB_TOKEN                      = ""
    TUNNELD_VERBOSE                  = "true"
    TUNNELD_LISTEN_ADDRESS           = "0.0.0.0:12345"
    TUNNELD_BASE_URL                 = "https://try.${var.domain}"
    TUNNELD_WIREGUARD_ENDPOINT       = "wg.${var.domain}:54321"
    TUNNELD_WIREGUARD_PORT           = "54321"
    TUNNELD_WIREGUARD_MTU            = "1280"
    TUNNELD_WIREGUARD_SERVER_IP      = "fcca::1"
    TUNNELD_WIREGUARD_NETWORK_PREFIX = "fcca::/16"
    TUNNELD_REAL_IP_HEADER           = "X-Forwarded-For"
    TUNNELD_PPROF_LISTEN_ADDRESS     = ""
    # TUNNELD_TRACING_HONEYCOMB_TEAM = ""
    # TUNNELD_TRACING_INSTANCE_ID
    # CODER_DERP_SERVER_REGION_NAME        = "Coder Embedded Relay"
    # CODER_DERP_FORCE_WEBSOCKETS          = "false"
    # CODER_DERP_SERVER_ENABLE             = "true"
    # CODER_DERP_SERVER_REGION_CODE        = "coder"
    # CODER_DERP_SERVER_REGION_ID          = "999"
    # CODER_DISABLE_SESSION_EXPIRY_REFRESH = "false"
    # CODER_TLS_REDIRECT_HTTP_TO_HTTPS     = "true"
    # CODER_REDIRECT_TO_ACCESS_URL         = "false"
    # CODER_SECURE_AUTH_COOKIE             = "false"
    # CODER_SESSION_DURATION               = "1 day"
    # CODER_STRICT_TRANSPORT_SECURITY      = "false"
    # CODER_DISABLE_OWNER_WORKSPACE_ACCESS = "false"
    # CODER_TRACE_ENABLE                   = "false"
    # CODER_TRACE_LOGS                     = "false"
    # CODER_VERBOSE                        = "false"
    # CODER_ENABLE_TERRAFORM_DEBUG_MODE    = "false"
    # CODER_LOGGING_HUMAN                  = "/dev/stderr"
    # CODER_PROMETHEUS_COLLECT_AGENT_STATS = "false"
    # CODER_PROMETHEUS_COLLECT_DB_METRICS  = "false"
    # CODER_TRACE_DATADOG                  = "false"
    # CODER_DISABLE_PASSWORD_AUTH          = "false"
    # CODER_MAX_TOKEN_LIFETIME              = "100 years"
    # CODER_PROXY_HEALTH_INTERVAL           = "1 minute"
    # CODER_HEALTH_CHECK_REFRESH            = "10 minutes"
    # CODER_HEALTH_CHECK_THRESHOLD_DATABASE = "15ms"
    # CODER_PPROF_ADDRESS                   = "127.0.0.1:6060"
    # CODER_PPROF_ENABLE                    = "false"
    # CODER_OIDC_EMAIL_DOMAIN = "ii.coop,cncf.io,linuxfoundation.org"
    # An HTTP URL that is accessible by other replicas to relay DERP traffic. Required for high availability.
    # CODER_DERP_SERVER_RELAY_URL = "https://XX"
    # CODER_OIDC_AUTH_URL_PARAMS = ""
    # CODER_PROMETHEUS_ADDRESS   = "0.0.0.0:2112"
    # TF_LOG                        = "debug"
    # https://coder.com/docs/v2/latest/admin/git-providers#multiple-git-providers-enterprise
    # Gitea ::
    # CODER_OIDC_ICON_URL = "https://gitea.io/images/gitea.png"
    # CODER_OIDC_SCOPES = "openid,profile,email,groups"
    # Gitlab ::
    # CODER_OIDC_ISSUER_URL = "https://gitlab.com"
    # CODER_OIDC_EMAIL_DOMAIN = "ii.coop,cncf.io,linuxfoundation.org"
    # Google ::
    # CODER_OIDC_ISSUER_URL = "https://accounts.google.com"
    # CODER_OIDC_EMAIL_DOMAIN = "ii.coop,cncf.io,linuxfoundation.org"
  }
  depends_on = [
    kubernetes_namespace.coder
  ]
}

resource "kubernetes_config_map" "coder_override" {
  metadata {
    name      = "coder-override"
    namespace = "coder"
  }

  data = {
    CODER_VERBOSE    = "true"
    CODER_LOG_FILTER = ".*userauth.*|.*groups returned.*"
  }
  lifecycle {
    ignore_changes = [
      # Ignore any changes to the configmap data
      # This should let us edit it cluster without the iteration loop
      data,
    ]
  }
}
resource "kubernetes_config_map_v1" "coder_config_hash" {
  metadata {
    name      = "coder-config-hash"
    namespace = "flux-system"
  }

  data = {
    confighash = sha1(jsonencode(merge(
      data.kubernetes_secret_v1.coder.data,
      data.kubernetes_config_map_v1.coder_kustomize.data,
      data.kubernetes_config_map_v1.coder_config.data,
    )))
  }
}
