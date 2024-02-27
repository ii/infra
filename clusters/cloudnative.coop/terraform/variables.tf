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

variable "controlplane_nodes" {
  description = "the number of controlplane nodes"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "cloudnative-coop"
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
  default     = "https://pxe.factory.talos.dev/pxe/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.6.5/metal-amd64"
  description = "https://factory.talos.dev"
}
variable "plan" {
  type        = string
  default     = "c3.medium.x86"
  description = "Equinix Metal machine plan"
}
