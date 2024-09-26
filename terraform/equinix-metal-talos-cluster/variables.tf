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
variable "equinix_metal_cloudprovider_controller_version" {
  type        = string
  default     = "v3.8.0"
  description = "https://github.com/kubernetes-sigs/cloud-provider-equinix-metal/releases"
}
variable "equinix_metal_plan" {
  type        = string
  default     = "c3.medium.x86"
  description = "Equinix Metal machine plan"
}

variable "controlplane_nodes" {
  description = "the number of controlplane nodes"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "a-very-cool-cluster"
}

variable "talos_version" {
  type        = string
  default     = "X"
  description = "Version of Talos to deploy"
}
# variable "ipxe_script_url" {


variable "talos_install_disk" {
  type        = string
  default     = "/dev/sda"
  description = "the disk for Talos to completely claim"
}

variable "longhorn_disk" {
  type        = string
  default     = "/dev/sdb"
  description = "the disk for Longhorn to completely claim"
}

# variable "talos_version" {
#   type        = string
#   default     = "v1.6.5"
#   description = "https://github.com/siderolabs/talos/releases"
# }
# variable "talos_install_image" {
#   type        = string
#   default     = "factory.talos.dev/installer/5cf0d58ea18983ce77fecf95b4a2f0a36143b4008ccff308cac995a18fbb27db:v1.6.6"
#   description = "https://github.com/siderolabs/talos/releases"
# }
variable "kubernetes_version" {
  type        = string
  default     = "v1.29.2"
  description = "Version of Kubernetes to deploy"
}
# variable "ipxe_script_url" {
#   type        = string
#   default     = ""
#   description = "https://factory.talos.dev"
# }

variable "kubernetes_apiserver_fqdn" {
  description = "domain for the apiserver to accept"
  type        = string
  default     = ""
}

variable "acme_email_address" {
  description = "the email address for LetsEncrypt"
  type        = string
  default     = ""
}
variable "rfc2136_nameserver" {
  description = "the nameserver address"
  type        = string
  default     = ""
}
variable "rfc2136_tsig_keyname" {
  description = "the rfc2136 name of the tsig key"
  type        = string
  default     = ""
}
variable "rfc2136_tsig_key" {
  description = "the "
  type        = string
  default     = ""
}
variable "rfc2136_algorithm" {
  description = "the algorithm to use for rfc2136"
  type        = string
  default     = ""
}
variable "domain" {
  description = "the DNS domain for records and certs"
  type        = string
  default     = ""
}
# variable "pdns_api_key" {
#   description = "the API key for PowerDNS"
#   type        = string
#   default     = ""
# }
# variable "pdns_host" {
#   description = "the host address for PowerDNS"
#   type        = string
#   default     = ""
# }
