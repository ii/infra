variable "equinix_metal_project_id" {
  description = "the project ID for the Equinix Metal project"
  type        = string
  default     = ""
}

variable "equinix_metal_auth_token" {
  description = "the api auth for the Equinix Metal, for virtual ip assignment"
  type        = string
  default     = ""
}

variable "rfc2136_nameserver" {
  description = "the DNS zone"
  type        = string
  default     = ""
}

variable "rfc2136_tsig_keyname" {
  description = "the tsig key name for talking to a RFC2136 compliant DNS server"
  type        = string
  default     = ""
}

variable "rfc2136_tsig_key" {
  description = "the tsig key for talking to a RFC2136 compliant DNS server"
  type        = string
  default     = ""
}

variable "github_token" {
  sensitive   = true
  type        = string
  description = "a PAT for GitHub auth"
}

variable "github_org" {
  type        = string
  description = "the org for the Flux repo (ii)"
  default     = "ii"
}

variable "github_repository" {
  type        = string
  description = "the Flux repo name (infra)"
  default     = "infra"
}

variable "pdns_api_key" {
  description = "the API key for PowerDNS"
  type        = string
  default     = ""
}
variable "pdns_host" {
  description = "the host address for PowerDNS"
  type        = string
  default     = ""
}
variable "acme_email_address" {
  description = "the email address for LetsEncrypt"
  type        = string
  default     = ""
}
variable "authentik_github_oauth_app_id" {
  description = "Github OAUTH app id"
  type        = string
  default     = ""
}
variable "authentik_github_oauth_app_secret" {
  description = "Github OAUTH app secrets"
  type        = string
  default     = ""
}
variable "coder_oauth2_github_client_id" {
  description = "Authenticating Coder directly to github (bypassing authentik)"
  type        = string
  default     = ""
}
variable "coder_oauth2_github_client_secret" {
  description = "Authenticating Coder directly to github (bypassing authentik)"
  type        = string
  default     = ""
}
variable "coder_gitauth_0_client_id" {
  description = "Retrieving a RW token to save prs / commits etc in workspaces"
  type        = string
  default     = ""
}
variable "coder_gitauth_0_client_secret" {
  description = "Retrieving a RW token to save prs / commits etc in workspaces"
  type        = string
  default     = ""
}
variable "metal_auth_token" {
  description = "For creating coder workspaces on hardware"
  type        = string
}
