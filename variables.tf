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

variable "rfc2136_server" {
  description = "the address for a RFC2136 compliant DNS server"
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
