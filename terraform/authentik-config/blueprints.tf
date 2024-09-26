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
