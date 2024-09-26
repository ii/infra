data "authentik_flow" "default-invalidation-flow" {
  slug = "default-invalidation-flow"
}
data "authentik_flow" "default-user-settings-flow" {
  slug = "default-user-settings-flow"
}

resource "authentik_brand" "ii" {
  domain              = var.domain
  default             = false
  branding_title      = "| ${var.domain}"
  branding_logo       = "https://ii.nz/assets/ii-fresh.png"
  branding_favicon    = "/static/dist/assets/icons/icon.png" # We should locate an old favicon
  flow_authentication = resource.authentik_flow.ii-authentication-flow.uuid
  flow_invalidation   = data.authentik_flow.default-invalidation-flow.id
  flow_user_settings  = data.authentik_flow.default-user-settings-flow.id
  # https://docs.goauthentik.io/docs/troubleshooting/access
  attributes = <<-EOT
  {
     "goauthentik.io/user/debug" : true
  }
  EOT
  # web_certificate     = ""
  # flow_device_code    = ""
  # flow_recovery       = ""
  # flow_unenrollment   = ""
}
