data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}
# data "authentik_flow" "default-authentication-flow" {
#   slug = "default-authentication-flow"
# }
data "authentik_flow" "default-enrollment-flow" {
  slug = "default-source-enrollment"
}

resource "authentik_source_oauth" "github" {
  name                = "github"
  slug                = "github"
  provider_type       = "github"
  user_path_template  = "goauthentik.io/sources/%(slug)s"
  authentication_flow = resource.authentik_flow.ii-source-authentication-flow.uuid
  enrollment_flow     = resource.authentik_flow.ii-source-enrollment-flow.uuid
  consumer_key        = var.github_oauth_app_id
  consumer_secret     = var.github_oauth_app_secret
  oidc_jwks_url       = "https://token.actions.githubusercontent.com/.well-known/jwks"
  # additional_scopes   = ""
  policy_engine_mode  = "any"
  user_matching_mode  = "identifier" #
  access_token_url    = "https://github.com/login/oauth/access_token"
  authorization_url   = "https://github.com/login/oauth/authorize"
  profile_url         = "https://api.github.com/user"
  oidc_well_known_url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# resource "authentik_provider_oauth2" "coder" {
#   name                       = "coder"
#   client_type                = "public" # OR confidential
#   client_id                  = var.authentik_coder_oidc_client_id
#   client_secret              = var.authentik_coder_oidc_client_secret
#   authorization_flow         = data.authentik_flow.default-authorization-flow.id
#   authentication_flow        = data.authentik_flow.default-authentication-flow.id
#   access_code_validity       = "minutes=1"
#   access_token_validity      = "minutes=10"
#   refresh_token_validity     = "days=30"
#   include_claims_in_id_token = true
#   issuer_mode                = "per_provider"
#   sub_mode                   = "user_email"
#   # jwks_sources               = [] # JWTs issued by sources can authenticate on behalf
#   # property_mappings = []
#   # redirect_uris              = []
#   # signing_key                = ""
# }

resource "authentik_policy_expression" "coder" {
  name       = "example"
  expression = "return True"
}

resource "authentik_policy_binding" "coder-access" {
  target = authentik_application.coder.uuid
  policy = authentik_policy_expression.coder.id
  order  = 0
}

# resource "authentik_application" "coder" {
#   name             = "coder"
#   slug             = "coder"
#   group            = "ii"
#   meta_description = "Coder for Sharing"
#   meta_icon        = "fh://heart"
#   # meta_launch_url    = "fh://heart"
#   open_in_new_tab    = false
#   policy_engine_mode = "any"
#   protocol_provider  = authentik_provider_oauth2.coder.id
# }

# resource "authentik_blueprint" "instance" {
#   name    = "blueprint-instance"
#   path    = "default/flow-default-authentication-flow.yaml"
#   enabled = false
#   context = jsonencode(
#     {
#       foo = "bar"
#     }
#   )
# }
