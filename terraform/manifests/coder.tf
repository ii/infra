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
    CODER_HOST            = "coder.sharing.io"
    CODER_ACCESS_URL      = "https://coder.${var.domain}"
    CODER_WILDCARD_DOMAIN = "sharing.io"
    CODER_VERSION         = "2.8.5" # Lastest as of March 9th 2024
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
    CODER_OIDC_CLIENT_ID              = random_bytes.authentik_coder_oidc_client_id.hex
    CODER_OIDC_CLIENT_SECRET          = random_bytes.authentik_coder_oidc_client_secret.hex
    METAL_AUTH_TOKEN                  = var.equinix_metal_auth_token
    TF_VAR_metal_project              = var.equinix_metal_project_id
    CODER_OAUTH2_GITHUB_CLIENT_ID     = var.coder_oauth2_github_client_id
    CODER_OAUTH2_GITHUB_CLIENT_SECRET = var.coder_oauth2_github_client_secret
    CODER_GITAUTH_0_CLIENT_ID         = var.coder_gitauth_0_client_id
    CODER_GITAUTH_0_CLIENT_SECRET     = var.coder_gitauth_0_client_secret
    # GITHUB_TOKEN                      = ""
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
    CODER_HOST                 = "coder.${var.domain}"
    CODER_ACCESS_URL           = "https://coder.${var.domain}"
    CODER_OIDC_SIGN_IN_TEXT    = "Sign in with sso.${var.domain}"
    CODER_OIDC_ISSUER_URL      = "https://sso.${var.domain}/application/o/coder/"
    TUNNEL_ACCESS_URL          = "https://try.${var.domain}"
    TUNNEL_WILDCARD_DOMAIN     = "try.${var.domain}"
    CODER_SSH_KEYGEN_ALGORITHM = "ed25519"
    CODER_PROVISIONER_DAEMONS  = "50"
    CODER_FIRST_USER_USERNAME  = "coder"
    CODER_FIRST_USER_EMAIL     = "coder@ii.coop"
    CODER_FIRST_USER_TRIAIL    = "true"
    CODER_ACCESS_URL           = "https://coder.${var.domain}"
    CODER_WILDCARD_DOMAIN      = "${var.domain}"
    CODER_WILDCARD_ACCESS_URL  = "*.${var.domain}"
    CODER_SWAGGER_ENABLE       = "true"
    CODER_TELEMETRY            = "false"
    CODER_GITAUTH_0_ID         = "github"
    CODER_GITAUTH_0_TYPE       = "github"
    CODER_GITAUTH_0_SCOPES     = "repo" # write:gpg_key"
    # CODER_PROMETHEUS_ADDRESS   = "0.0.0.0:2112"
    # CODER_OIDC_SIGN_IN_TEXT       = "Sign in with sso.${var.domain}" # authentik as OIDC
    # CODER_OIDC_ISSUER_URL         = "https://sso.${var.domain}/application/o/codercontainer/"
    # CODER_OIDC_ICON_URL           = "https://goauthentik.io/img/icon.png"
    # CODER_OIDC_GROUP_FIELD        = "groups" #  https://coder.com/docs/v2/latest/admin/auth#group-sync-enterprise
    # CODER_OIDC_GROUP_MAPPING      = <<-EOT
    #        {"authentik Admins": "Coder Admins"}
    #        EOT
    # CODER_OIDC_GROUP_AUTO_CREATE  = "true"
    # CODER_OIDC_GROUP_REGEX_FILTER = "^Coder.*$"
    # CODER_OIDC_SCOPES             = "openid,profile,email,groups"
    # TF_LOG                        = "debug"
    # # CODER_VERBOSE                 = "true"
    # CODER_OIDC_USER_ROLE_FIELD   = "groups" # https://coder.com/docs/v2/latest/admin/auth#role-sync-enterprise
    # CODER_OIDC_USER_ROLE_MAPPING = <<-EOT
    #         {
    #           "authentik Admins": [ "owner", "template-admin", "user-admin", "auditor" ]
    #         }
    #         EOT
    CODER_DISABLE_PASSWORD_AUTH = "false"
    # CODER_OAUTH2_GITHUB_ALLOW_SIGNUPS = "true"
    CODER_OAUTH2_GITHUB_ALLOW_EVERYONE = "true"
    # CODER_OAUTH2_GITHUB_ALLOWED_ORGS = "ii,coder,kubermatic"
    # CODER_OIDC_USERNAME_FIELD = "preferred_username"
    # CODER_OIDC_EMAIL_DOMAIN = "ii.coop,cncf.io,linuxfoundation.org"
    # CODER_OIDC_EMAIL_FIELD  = "email"
    # CODER_OIDC_IGNORE_EMAIL_VERIFIED = "true"
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
