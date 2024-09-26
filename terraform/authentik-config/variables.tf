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

variable "cluster_name" {
  type        = string
  description = "the target cluster name"
  default     = ""
}

variable "kubeconfig" {
  type        = string
  description = "the target cluster Kubeconfig"
  default     = ""
}



variable "github_oauth_app_id" {
  description = "Authentik SSO OAUTH with github : the APP ID"
  type        = string
}
variable "github_oauth_app_secret" {
  description = "Authentik SSO OAUTH with github : the APP SECRET"
  type        = string
}

variable "authentik_coder_oidc_client_id" {
  description = "Coder SSO OAUTH with authentik : the APP ID"
  type        = string
}

variable "authentik_coder_oidc_client_secret" {
  description = "Coder SSO OAUTH with authentik : the APP SECRET"
  type        = string
}
variable "authentik_bootstrap_token" {
  description = "Authentik ADMIN token for use with terraform"
  type        = string
}

variable "domain" {
  description = "root domain hosting our services"
  type        = string
}
