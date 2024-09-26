# I did try to create our own ii-source-enrollment-flow
# but I got errors and tracebacks. Loop back another time
# Just use the default one for now. It works.

data "authentik_flow" "default-source-enrollment" {
  slug = "default-source-enrollment"
}
resource "authentik_flow" "ii-source-enrollment-flow" {
  name               = "Welcome to ii! Please select a username."
  title              = "It's a great day to choose a user"
  slug               = "ii-source-enrollment-flow"
  designation        = "enrollment"
  authentication     = "none"
  compatibility_mode = true
  denied_action      = "message_continue"
  policy_engine_mode = "any"
  layout             = "stacked"
  background         = "/static/dist/assets/images/flow_background.jpg"
}

resource "authentik_flow" "ii-enrollment-flow" {
  name               = "Welcome to ii! Please select a username."
  title              = "It's a great day to choose a user"
  slug               = "ii-enrollment-flow"
  designation        = "enrollment"
  authentication     = "none"
  compatibility_mode = true
  denied_action      = "message_continue"
  policy_engine_mode = "any"
  layout             = "stacked"
  background         = "/static/dist/assets/images/flow_background.jpg"
}


resource "authentik_stage_prompt_field" "username" {
  name      = "ii username" # Unique, for selecting prompts
  field_key = "username"    # form field
  label     = "Username"    # label shown next/to above
  type      = "username"
  required  = true
  sub_text  = "Choose a good hackername" # help text
  # placeholder              = "MYUSERNAME"
  # placeholder_expression   = false
  # initial_value            = "MYUSERNAME"
  # initial_value_expression = false
  order = 100
}

resource "authentik_stage_prompt_field" "name" {
  name      = "ii name" # Unique, for selecting prompts
  field_key = "name"    # form field
  label     = "Name"    # label shown next/to above
  type      = "text"
  required  = true
  sub_text  = "Choose a Name for Yourself" # help text
  # placeholder              = "MYUSERNAME"
  # placeholder_expression   = false
  initial_value_expression = true
  initial_value            = <<-EOT
  try:
      return user.name
  except:
      return ''
  EOT
  order                    = 200
}

resource "authentik_stage_prompt_field" "email" {
  name                     = "ii email" # Unique, for selecting prompts
  field_key                = "email"    # form field
  label                    = "Email"    # label shown next/to above
  type                     = "email"
  required                 = true
  sub_text                 = "Provide your email" # help text
  placeholder              = "Email"
  placeholder_expression   = false
  initial_value_expression = true
  initial_value            = <<-EOT
  try:
      return user.email
  except:
      return ''
  EOT
  order                    = 300
}

resource "authentik_stage_prompt_field" "password" {
  name                     = "ii password" # Unique, for selecting prompts
  field_key                = "password"    # form field
  label                    = "Password"    # label shown next/to above
  type                     = "password"
  required                 = true
  sub_text                 = "Provide your Password" # help text
  placeholder              = "Password"
  placeholder_expression   = false
  initial_value_expression = false
  initial_value            = ""
  order                    = 400
}


resource "authentik_stage_prompt_field" "password_repeat" {
  name                     = "ii password again" # Unique, for selecting prompts
  field_key                = "password_repeat"   # form field
  label                    = "Password (Again)"  # label shown next/to above
  type                     = "password"
  required                 = true
  sub_text                 = "Provide your Password" # help text
  placeholder              = "Password (repeat)"
  placeholder_expression   = false
  initial_value_expression = false
  initial_value            = ""
  order                    = 500
}

resource "authentik_policy_expression" "ii_authentication_flow_password_stage" {
  name       = "ii-authentication-flow-password-stage"
  expression = <<-EOT
  flow_plan = request.context.get("flow_plan")
  if not flow_plan:
      return True
  # If the user does not have a backend attached to it, they haven't
  # been authenticated yet and we need the password stage
  return not hasattr(flow_plan.context.get("pending_user"), "backend")
  EOT
}

resource "authentik_stage_prompt" "ii-enrollment-prompt" {
  name = "ii-enrollment-prompt"
  fields = [
    resource.authentik_stage_prompt_field.username.id,
    resource.authentik_stage_prompt_field.name.id,
    resource.authentik_stage_prompt_field.email.id,
    resource.authentik_stage_prompt_field.password.id,
    resource.authentik_stage_prompt_field.password_repeat.id,
  ]
  validation_policies = [
    resource.authentik_policy_expression.ii_authentication_flow_password_stage.id,
  ]
}


resource "authentik_flow_stage_binding" "ii-enrollment-prompt" {
  target                  = authentik_flow.ii-enrollment-flow.uuid
  stage                   = authentik_stage_prompt.ii-enrollment-prompt.id
  order                   = 10
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

resource "authentik_stage_user_write" "ii-enrollment-write" {
  name                     = "ii-enrollment-write"
  create_users_as_inactive = false
  user_creation_mode       = "create_when_required"
  user_path_template       = "" # This shows Internal, External, and Service Account
  # create_user_group       = "" # Could set as admin here
}

resource "authentik_flow_stage_binding" "ii-enrollment-write" {
  target                  = authentik_flow.ii-enrollment-flow.uuid
  stage                   = authentik_stage_user_write.ii-enrollment-write.id
  order                   = 20
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}

resource "authentik_stage_user_login" "ii-enrollment-login" {
  name                     = "ii-enrollment-login"
  geoip_binding            = "no_binding" # bind_continent_country_city
  network_binding          = "no_binding" # bind_asn_network_ip
  session_duration         = "hours=24"
  remember_me_offset       = "hours=72" # Stay sign in for
  terminate_other_sessions = false
  # session_duration         = "seconds=0"
  # remember_me_offset       = "seconds=0" # Stay sign in for
}

resource "authentik_flow_stage_binding" "ii-enrollment-login" {
  target                  = authentik_flow.ii-enrollment-flow.uuid
  stage                   = authentik_stage_user_login.ii-enrollment-login.id
  order                   = 30
  evaluate_on_plan        = false
  re_evaluate_policies    = true
  invalid_response_action = "retry"
  policy_engine_mode      = "any"
}
