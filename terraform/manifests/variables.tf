variable "equinix_metal_project_id" {
  description = "the project ID for the Equinix Metal project"
  type        = string
  default     = ""
}

variable "equinix_metal_metro" {
  description = "the metro for the Equinix Metal resources"
  type        = string
  default     = "sv"
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
variable "rfc2136_tsig_algorithm" {
  description = "the algorithm to use for rfc2136"
  type        = string
  default     = ""
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
variable "ingress_ip" {
  description = "ip for the ingress controller service"
  type        = string
  default     = ""
}
variable "dns_ip" {
  description = "ip for the Power DNS service"
  type        = string
  default     = ""
}
variable "wg_ip" {
  description = "ip for the WireGuard tunneld service"
  type        = string
  default     = ""
}

variable "domain" {
  description = "the DNS domain for records and certs"
  type        = string
  default     = ""
}
variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "a-very-cool-cluster"
}
variable "coder_version" {
  description = "Version of Coder to deploy"
  type        = string
}
variable "coder_oauth2_github_client_id" {
  description = "Authenticating Coder directly to github (bypassing authentik)"
  type        = string
}
variable "coder_oauth2_github_client_secret" {
  description = "Authenticating Coder directly to github (bypassing authentik)"
  type        = string
}
variable "coder_gitauth_0_client_id" {
  description = "Retrieving a RW token to save prs / commits etc in workspaces"
  type        = string
}
variable "coder_gitauth_0_client_secret" {
  description = "Retrieving a RW token to save prs / commits etc in workspaces"
  type        = string
}
variable "authentik_version" {
  description = "Version of Authentik to deploy"
  type        = string
}
