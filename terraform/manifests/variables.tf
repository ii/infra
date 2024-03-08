variable "k8s_host" {
  type        = string
  description = "URI of cluster"
}
variable "k8s_client_certificate" {
  type        = string
  description = "PEM-encoded root certificates bundle for TLS client authentication"
}
variable "k8s_client_key" {
  type        = string
  description = "PEM-encoded client certificate key for TLS client authentication."
}
variable "k8s_cluster_ca_certificate" {
  type        = string
  description = "PEM-encoded root certificates bundle for TLS server authentication."
}
