variable "compartment_ocid" {
  sensitive = true
}
variable "tenancy_ocid" {
  sensitive = true
}
variable "user_ocid" {
  sensitive = true
}
variable "fingerprint" {
  sensitive = true
}
variable "private_key_path" {
  default   = "~/.oci/oci_main_terraform.pem"
  sensitive = true
}
variable "instance_availability_domain" {
  default = null
}
variable "region" {
  description = "the OCI region where resources will be created"
  type        = string
  default     = null
}
variable "cluster_name" {
  type    = string
  default = "cncfoke"
}
variable "cluster_kubernetes_version" {
  type    = string
  default = "v1.30.1"
}
variable "cidr_blocks" {
  type    = set(string)
  default = ["10.0.0.0/16"]
}
variable "subnet_block" {
  type    = string
  default = "10.0.0.0/24"
}
variable "pod_subnet_block" {
  type    = string
  default = "10.32.0.0/12"
}
variable "service_subnet_block" {
  type    = string
  default = "10.200.0.0/21"
}
variable "node_subnet_block" {
  type    = string
  default = "10.0.7.0/24"
}
variable "node_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}
variable "node_memory_in_gbs" {
  type    = number
  default = 128
}
variable "node_ocpus" {
  type    = number
  default = 8
}
variable "node_pool_count" {
  type    = number
  default = 3
}
