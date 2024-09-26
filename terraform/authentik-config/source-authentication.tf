# resource "authentik_flow" "ii-source-enrollment" {
#   name               = "Welcome to ${var.domain} ii-source-enrollment"
#   title              = "ii Enrollment for ${var.domain}i :: Select a username."
#   slug               = "ii-source-enrollment"
#   designation        = "enrollment"
#   authentication     = "none"
#   compatibility_mode = true
#   denied_action      = "message_continue"
#   policy_engine_mode = "any"
#   layout             = "stacked"
#   background         = "/static/dist/assets/images/flow_background.jpg"
# }

resource "authentik_flow" "ii-source-authentication-flow" {
  name               = "ii-source-authentication-flow"
  title              = "ii Single Sign On for ${var.domain}"
  slug               = "ii-source-authentication-flow"
  designation        = "authentication"
  authentication     = "none"
  compatibility_mode = true
  denied_action      = "message_continue"
  policy_engine_mode = "any"
  layout             = "stacked"
  background         = "/static/dist/assets/images/flow_background.jpg"
}

resource "authentik_stage_user_login" "ii-source-authentication-login" {
  name                     = "ii-source-authentication-login"
  geoip_binding            = "no_binding" # bind_continent_country_city
  network_binding          = "no_binding" # bind_asn_network_ip
  session_duration         = "seconds=0"
  remember_me_offset       = "seconds=0" # Stay sign in for
  terminate_other_sessions = false
}

resource "authentik_flow_stage_binding" "ii-source-authentication-login" {
  target                  = authentik_flow.ii-source-authentication-flow.uuid
  order                   = 0
  stage                   = authentik_stage_user_login.ii-source-authentication-login.id
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

resource "authentik_policy_expression" "ii-source-enrollment-if-sso" {
  name       = "ii-source-enrollment-if-sso"
  expression = <<-EOT
    # This policy ensures that this flow can only be used when the user
    # is in a SSO Flow (meaning they come from an external IdP)
    return ak_is_sso_flow
  EOT
}

resource "authentik_policy_binding" "ii-source-authentication-if-username" {
  target         = authentik_flow.ii-source-authentication-flow.uuid
  policy         = authentik_policy_expression.ii-source-enrollment-if-username.id
  enabled        = true
  negate         = false
  order          = 0
  timeout        = 30
  failure_result = false # Result used when policy execution fails.
}

resource "authentik_policy_expression" "ii-source-enrollment-if-username" {
  name       = "ii-source-enrollment-if-username"
  expression = <<-EOT
    # Check if we''ve not been given a username by the external IdP
    # and trigger the enrollment flow
    return 'username' not in context.get('prompt_data', {})
  EOT
}

resource "authentik_policy_binding" "ii-source-enrollment-if-sso" {
  target         = authentik_flow.ii-source-enrollment-flow.uuid
  policy         = authentik_policy_expression.ii-source-enrollment-if-sso.id
  enabled        = true
  negate         = false
  order          = 0
  timeout        = 30
  failure_result = false # Result used when policy execution fails.
}

resource "authentik_stage_prompt_field" "ii-source-enrollment-field-username" {
  name      = "ii enrollment username" # Unique, for selecting prompts
  field_key = "username"               # form field
  label     = "Username"               # label shown next/to above
  type      = "text"
  required  = true
  sub_text  = "Choose a good hackername" # help text
  # placeholder              = "MYUSERNAME"
  # placeholder_expression   = false
  # initial_value            = "MYUSERNAME"
  # initial_value_expression = false
  order = 100
}

resource "authentik_stage_prompt" "ii-source-enrollment-prompt" {
  name = "ii-source-enrollment-prompt"
  fields = [
    resource.authentik_stage_prompt_field.ii-source-enrollment-field-username.id,
  ]
  validation_policies = [
  ]
}

resource "authentik_flow_stage_binding" "ii-source-enrollment-prompt" {
  target                  = authentik_flow.ii-source-enrollment-flow.uuid
  stage                   = authentik_stage_prompt.ii-source-enrollment-prompt.id
  order                   = 10
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

resource "authentik_policy_binding" "ii-source-enrollment-if-username" {
  target         = authentik_flow_stage_binding.ii-source-enrollment-prompt.id
  policy         = authentik_policy_expression.ii-source-enrollment-if-username.id
  enabled        = true
  negate         = false
  order          = 10
  timeout        = 30
  failure_result = false # Result used when policy execution fails.
}
resource "authentik_stage_user_write" "ii-source-enrollment-write" {
  name                     = "ii-source-enrollment-write"
  create_users_as_inactive = false
  user_creation_mode       = "create_when_required"
  user_path_template       = "" # This shows Internal, External, and Service Account
  # create_user_group       = "" # Could set as admin here
}

resource "authentik_flow_stage_binding" "ii-source-enrollment-write" {
  target                  = authentik_flow.ii-source-enrollment-flow.uuid
  stage                   = authentik_stage_user_write.ii-source-enrollment-write.id
  order                   = 20
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

resource "authentik_stage_user_login" "ii-source-enrollment-login" {
  name                     = "ii-source-enrollment-login"
  geoip_binding            = "no_binding" # bind_continent_country_city
  network_binding          = "no_binding" # bind_asn_network_ip
  session_duration         = "hours=24"
  remember_me_offset       = "hours=72" # Stay sign in for
  terminate_other_sessions = false
  # session_duration         = "seconds=0"
  # remember_me_offset       = "seconds=0" # Stay sign in for
}

resource "authentik_flow_stage_binding" "ii-source-enrollment-login" {
  target                  = authentik_flow.ii-source-enrollment-flow.uuid
  stage                   = authentik_stage_user_login.ii-source-enrollment-login.id
  order                   = 30
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}
# resource "authentik_policy_binding" "ii-source-enrollment-if-username" {
#   target  = authentik_flow.ii-source-enrollment-flow.uuid
#   policy  = authentik_policy_expression.ii-source-enrollment-if-username.id
#   enabled = true
#   negate  = false
#   order   = 0
#   timeout = 30
# }
# resource "authentik_policy_expression" "coder" {
#   name       = "example"
#   expression = "return True"
# resource "authentik_policy_binding" "coder-access" {
#   target = authentik_application.coder.uuid
#   policy = authentik_policy_expression.coder.id
#   order  = 0
# }
