data "authentik_source" "built-in" {
  slug = "authentik-built-in"
}

resource "authentik_flow" "ii-authentication-flow" {
  name               = "Our name is SSO.${var.domain}"
  title              = "Click Github Icon or Signup Below"
  slug               = "ii-authentication-flow"
  designation        = "authentication"
  authentication     = "none"
  compatibility_mode = true
  denied_action      = "message_continue"
  policy_engine_mode = "any"
  layout             = "stacked"
  background         = "/static/dist/assets/images/flow_background.jpg"
}

resource "authentik_stage_identification" "ii-identification-stage" {
  name = "ii-authentication-identification"
  user_fields = [
    "username",
    "email"
  ]
  # password_stage = authentik_stage_password.name.id
  case_insensitive_matching = true
  show_matched_user         = true
  sources = [
    data.authentik_source.built-in.uuid,
    authentik_source_oauth.github.uuid,
  ]
  show_source_labels = false
  enrollment_flow    = authentik_flow.ii-enrollment-flow.uuid
  # passwordless_low = ""
  lifecycle {
    ignore_changes = [
      # Ignore any changes to the secret data
      # This should let us edit it cluster without the iteration loop
      sources,
    ]
  }
}

resource "authentik_flow_stage_binding" "ii-authentication-identification" {
  target                  = authentik_flow.ii-authentication-flow.uuid
  order                   = 10
  stage                   = authentik_stage_identification.ii-identification-stage.id
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

data "authentik_stage" "default-authentication-password" {
  name = "default-authentication-password"
}

resource "authentik_flow_stage_binding" "ii-authentication-password" {
  target = authentik_flow.ii-authentication-flow.uuid
  order  = 20
  stage  = data.authentik_stage.default-authentication-password.id
  # stage = authentik_stage_password.ii-authentication-password.id
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

data "authentik_stage" "default-authentication-mfa-validation" {
  name = "default-authentication-mfa-validation"
}


resource "authentik_flow_stage_binding" "ii-authentication-mfa-validation" {
  target                  = authentik_flow.ii-authentication-flow.uuid
  order                   = 30
  stage                   = data.authentik_stage.default-authentication-mfa-validation.id
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"

}

data "authentik_stage" "default-authentication-login" {
  name = "default-authentication-login"
}

resource "authentik_flow_stage_binding" "ii-authentication-login" {
  target                  = authentik_flow.ii-authentication-flow.uuid
  order                   = 100
  stage                   = data.authentik_stage.default-authentication-login.id
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"

}


resource "authentik_stage_authenticator_validate" "ii-authentication-mfa-validation" {
  name = "ii-authentication-mfa-validation"
  device_classes = [
    "static"
  ]
  last_auth_threshold        = "seconds=0"
  not_configured_action      = "skip" # or deny or configure
  webauthn_user_verification = "preferred"
}

# resource "authentik_policy_binding" "ii-authentication-if-sso" {
#   target         = authentik_flow.ii-authentication-flow.uuid
#   policy         = authentik_policy_expression.ii-source-enrollment-if-sso.id
#   enabled        = true
#   negate         = false
#   order          = 0
#   timeout        = 30
#   failure_result = false # Result used when policy execution fails.
# }

# resource "authentik_policy_expression" "ii-enrollment-if-sso" {
#   name       = "ii-enrollment-if-sso"
#   expression = <<-EOT
#     # This policy ensures that this flow can only be used when the user
#     # is in a SSO Flow (meaning they come from an external IdP)
#     return ak_is_sso_flow
#   EOT
# }

# resource "authentik_policy_binding" "ii-enroll-if-sso" {
#   target         = authentik_flow.ii-authentication-flow.uuid
#   policy         = authentik_policy_expression.ii-enrollment-if-sso.id
#   enabled        = true
#   negate         = false
#   order          = 0
#   timeout        = 30
#   failure_result = false # Result used when policy execution fails.
# }

# resource "authentik_policy_expression" "coder" {
#   name       = "example"
#   expression = "return True"
# }

# resource "authentik_policy_binding" "coder-access" {
#   target = authentik_application.coder.uuid
#   policy = authentik_policy_expression.coder.id
#   order  = 0
# }
