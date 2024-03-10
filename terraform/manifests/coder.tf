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
resource "random_string" "coder_password" {
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
    CODER_WILDCARD_DOMAIN = "sharing.io"
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
    CODER_PASSWORD                    = random_string.coder_password.result
    CODER_OAUTH2_GITHUB_CLIENT_ID     = var.coder_oauth2_github_client_id
    CODER_OAUTH2_GITHUB_CLIENT_SECRET = var.coder_oauth2_github_client_secret
    CODER_GITAUTH_0_CLIENT_ID         = var.coder_gitauth_0_client_id
    CODER_GITAUTH_0_CLIENT_SECRET     = var.coder_gitauth_0_client_secret
    CODER_OIDC_CLIENT_ID              = random_string.authentik_coder_oidc_client_id.result
    CODER_OIDC_CLIENT_SECRET          = random_string.authentik_coder_oidc_client_secret.result
    METAL_AUTH_TOKEN                  = var.metal_auth_token
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
    CODER_HOST                    = "coder.sharing.io"
    CODER_ACCESS_URL              = "https://coder.sharing.io"
    CODER_WILDCARD_DOMAIN         = "sharing.io"
    CODER_OIDC_SIGN_IN_TEXT       = "Sign in with sso.sharing.io"
    CODER_OIDC_ISSUER_URL         = "https://sso.sharing.io/application/o/coder/"
    TUNNEL_ACCESS_URL             = "https://try.sharing.io"
    TUNNEL_WILDCARD_DOMAIN        = "try.sharing.io"
    CODER_SSH_KEYGEN_ALGORITHM    = "ed25519"
    CODER_PROVISIONER_DAEMONS     = "50"
    CODER_USERNAME                = "coder"
    CODER_EMAIL                   = "coder@ii.coop" # used by /opt/coder server create-admin-user
    CODER_ACCESS_URL              = "https://coder.sharing.io"
    CODER_WILDCARD_ACCESS_URL     = "*.sharing.io"
    CODER_SWAGGER_ENABLE          = "true"
    CODER_PROMETHEUS_ADDRESS      = "0.0.0.0:2112"
    CODER_TELEMETRY               = "false"
    CODER_GITAUTH_0_ID            = "github"
    CODER_GITAUTH_0_TYPE          = "github"
    CODER_GITAUTH_0_SCOPES        = "repo"            # write:gpg_key"
    CODER_OIDC_SIGN_IN_TEXT       = "sso.company.com" # authentik as OIDC
    CODER_OIDC_ISSUER_URL         = "https:sso.company.com/application/o/codercontainer/"
    CODER_OIDC_ICON_URL           = "https://goauthentik.io/img/icon.png"
    CODER_OIDC_GROUP_FIELD        = "groups" #  https://coder.com/docs/v2/latest/admin/auth#group-sync-enterprise
    CODER_OIDC_GROUP_MAPPING      = <<-EOT
           {"authentik Admins": "Coder Admins"}
           EOT
    CODER_OIDC_GROUP_AUTO_CREATE  = "true"
    CODER_OIDC_GROUP_REGEX_FILTER = "^Coder.*$"
    CODER_OIDC_SCOPES             = "openid,profile,email,groups"
    TF_LOG                        = "debug"
    CODER_OIDC_USER_ROLE_FIELD    = "groups" # https://coder.com/docs/v2/latest/admin/auth#role-sync-enterprise
    CODER_OIDC_USER_ROLE_MAPPING  = <<-EOT
    # CODER_VERBOSE                 = "true"
            {
              "authentik Admins": [ "owner", "template-admin", "user-admin", "auditor" ]
            }
            EOT
    CODER_DISABLE_PASSWORD_AUTH   = "false"
    TF_VAR_metal_project          = "82b5c425-8dd4-429e-ae0d-d32f265c63e4"
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
