
resource "authentik_application" "coder" {
  name               = "coder"
  slug               = "coder"
  group              = "ii"
  meta_description   = "Coder for Sharing"
  meta_icon          = "https://avatars.githubusercontent.com/u/95932066?s=200&v=4"
  meta_launch_url    = "https://coder.${var.domain}/api/v2/users/oidc/callback?redirect=%2F"
  open_in_new_tab    = false
  policy_engine_mode = "any"
  protocol_provider  = authentik_provider_oauth2.coder.id
}


data "authentik_scope_mapping" "coder" {
  # Search by name, by managed field or by scope_name
  # name    = "authentik default OAuth Mapping: Proxy outpost"
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-offline_access",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "coder" {
  name                       = "coder"
  client_type                = "confidential" # OR public
  client_id                  = var.authentik_coder_oidc_client_id
  client_secret              = var.authentik_coder_oidc_client_secret
  authorization_flow         = data.authentik_flow.default-provider-authorization-implicit-consent.id
  authentication_flow        = data.authentik_flow.default-authentication-flow.id
  access_code_validity       = "minutes=1"
  access_token_validity      = "minutes=10"
  refresh_token_validity     = "days=30"
  include_claims_in_id_token = true
  issuer_mode                = "per_provider"
  sub_mode                   = "user_email"
  signing_key                = data.authentik_certificate_key_pair.default.id
  redirect_uris = [
    "https://coder.${var.domain}/api/v2/users/oidc/callback"
  ]
  # authorization_flow         = data.authentik_flow.default-authorization-flow.id
  # authentication_flow = authentik_flow.ii-authentication-flow.uuid
  # authorization_flow         = authentik_flow.ii-provider-authorization-implicent-consent.id
  # jwks_sources               = [authentik_source_oauth.github.uuid] # JWTs issued by sources can authenticate on behalf
  # Debugging WHY it's removing the property mappings, maybe these get set automaticallay?:
  #
  #  # module.cluster-authentik-config.authentik_provider_oauth2.coder will be updated in-place
  # ~ resource "authentik_provider_oauth2" "coder" {
  #     ~ authentication_flow        = "1e5c8390-5011-4827-9741-b3267ea6161c" -> (known after apply)
  #     ~ authorization_flow         = "8964062d-3236-4c41-b3c9-7e011dfeff74" -> (known after apply)
  #       id                         = "1"
  #       name                       = "coder"
  #     ~ property_mappings          = [
  #         - "4a6c2694-8624-4949-96bc-51b712ebe1e8",
  #         - "521f16c1-8146-474e-bddf-ac5f2eb0a487",
  #         - "fd765d66-ba3d-4d94-801d-b71c893c91e1",
  #         - "a5db65be-d87d-4cb1-9991-14a1146710ab",
  #       ] -> (known after apply)
  #     ~ signing_key                = "62c4656a-8137-4c10-a7cf-655fac74094a" -> (known after apply)
  #       # (11 unchanged attributes hidden)
  #   }
  property_mappings = data.authentik_scope_mapping.coder.ids
  lifecycle {
    ignore_changes = [
      # Ignore any changes to the secret data
      # This should let us edit it cluster without the iteration loop
      property_mappings,
    ]
  }
}
