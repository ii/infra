resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      metadata["labels"],
    ]
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
# TODO move outside the manifest module
resource "random_string" "authentik_postgresql_password" {
  length  = 16
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
    AUTHENTIK_BOOTSTRAP_PASSWORD   = random_string.authentik_bootstrap_password.result
    AUTHENTIK_BOOTSTRAP_TOKEN      = random_string.authentik_bootstrap_token.result
    AUTHENTIK_SECRET_KEY           = random_string.authentik_secret_key.result
    AUTHENTIK_POSTGRESQL__PASSWORD = random_string.authentik_postgresql_password.result
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
}

resource "kubernetes_secret_v1" "authentik_override" {
  metadata {
    name      = "authentik-override"
    namespace = "authentik"
  }

  data = {
    AUTHENTIK_OVERRIDES = "edit this manually within the cluster for temporary overrides"
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
  lifecycle {
    ignore_changes = [
      # Ignore any changes to the secret data
      # This should let us edit it cluster without the iteration loop
      data,
    ]
  }
}
resource "kubernetes_config_map" "authentik_override" {
  metadata {
    name      = "authentik-override"
    namespace = "authentik"
  }
  # https://docs.goauthentik.io/docs/installation/configuration#authentik-settings
  data = {
    AUTHENTIK_LOG_LEVEL = "debug"
    AUTHENTIK_DEBUG     = "true"
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
  lifecycle {
    ignore_changes = [
      # Ignore any changes to the secret data
      # This should let us edit it cluster without the iteration loop
      data,
    ]
  }
}
resource "kubernetes_config_map" "authentik_env" {
  metadata {
    name      = "authentik-env"
    namespace = "authentik"
  }
  # https://docs.goauthentik.io/docs/installation/configuration#authentik-settings
  data = {
    AUTHENTIK_BOOTSTRAP_EMAIL = "sharing.io@ii.coop"
    # AUTHENTIK_LOG_LEVEL       = "debug"
    # AUTHENTIK_DEBUG           = "true"
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
}
resource "kubernetes_config_map" "authentik-kustomize" {
  metadata {
    name      = "authentik-kustomize"
    namespace = "flux-system"
  }

  data = {
    authentik_host    = "sso.${var.domain}"
    AUTHENTIK_VERSION = "${var.authentik_version}"
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
}

# TODO: figure out what blueprints are and create a confmap for them
resource "kubernetes_config_map" "authentik_blueprints" {
  metadata {
    name      = "blueprints"
    namespace = "authentik"
  }

  data = {
    X = "MYBLUEPRINT"
    Y = "YOURBLUEPRINT"
  }
  depends_on = [
    kubernetes_namespace.authentik
  ]
}

resource "random_password" "authentik_coder_oidc_client_id" {
  length  = 64
  special = false
}

resource "random_password" "authentik_coder_oidc_client_secret" {
  length  = 64
  special = false
}

resource "kubernetes_config_map_v1" "authentik_config_hash" {
  metadata {
    name      = "authentik-config-hash"
    namespace = "flux-system"
  }

  data = {
    confighash = sha1(jsonencode(merge(
      data.kubernetes_secret_v1.authentik_env.data,
      data.kubernetes_config_map_v1.authentik_env.data,
    )))

  }
}
