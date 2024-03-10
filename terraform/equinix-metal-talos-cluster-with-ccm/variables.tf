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
  default     = "v1.6.5"
  description = "https://github.com/siderolabs/talos/releases"
}
variable "kubernetes_version" {
  type        = string
  default     = "v1.29.2"
  description = "https://github.com/siderolabs/kubelet/pkgs/container/kubelet"
}
variable "ipxe_script_url" {
  type        = string
  default     = "https://pxe.factory.talos.dev/pxe/0c2f6ca92c4bb5f7b79de5849bd2e96e026df55e4c18939df217e4f7d092a7c6/v1.6.5/metal-amd64"
  description = "https://factory.talos.dev"
}

variable "kube_apiserver_domain" {
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
