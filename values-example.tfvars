# Usage

# vars:

# - rfc2136_server
# - rfc2136_tsig_keyname
# - rfc2136_tsig_key
# - equinix_metal_project_id
# - equinix_metal_auth_token (DO NOT WRITE THIS DISK)

# keep in values.tfvars (as HCL); example:

acme_email_address                = "acme@ii.coop"
rfc2136_nameserver                = "123.253.176.253"
rfc2136_tsig_keyname              = "sharing.io."
rfc2136_tsig_key                  = ""
equinix_metal_project_id          = "82b5c425-8dd4-429e-ae0d-d32f265c63e4"
pdns_host                         = "https://powerdns.ii.nz"
pdns_api_key                      = ""
authentik_github_oauth_app_id     = "c7520aad04e0c107e598"
authentik_github_oauth_app_secret = ""
coder_oauth2_github_client_id     = "7757e9b13e1bcf985dde"
coder_oauth2_github_client_secret = ""
# https://github.com/organizations/sharingio/settings/apps/coder-sharing-io-gitauth
coder_gitauth_0_client_id     = "Iv1.d0ef76ee2c92e900"
coder_gitauth_0_client_secret = ""
# Equinix User Account Token (needed to create Load Balancers)
# project tokens don't work!
metal_auth_token = ""
