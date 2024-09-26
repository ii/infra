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

variable "cluster" {
  type        = string
  description = "the target cluster name"
  default     = "cluster"
}

variable "kubeconfig" {
  type        = string
  description = "the target cluster Kubeconfig"
  default     = ""
}
