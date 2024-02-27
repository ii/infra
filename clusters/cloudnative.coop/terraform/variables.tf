variable "equinix_metal_project_id" {
  description = "the project ID for the Equinix Metal project"
  type        = string
  default     = ""
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

variable "virtual_ip" {
  description = "The Equinix Metal floating IP"
  type        = string
  default     = "145.40.90.158"
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
  default     = "https://145.40.90.158:6443"
}
