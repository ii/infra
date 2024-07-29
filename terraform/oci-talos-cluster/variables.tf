variable "compartment_ocid" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "key_file" {
  default = "~/.oci/oci_main_terraform.pem"
}
variable "project" {
  type    = string
  default = "main"
}
variable "instance_availability_domain" {
  default = "bzBe:US-SANJOSE-1-AD-1"
}
variable "region" {
  description = "the OCI region where resources will be created"
  type        = string
  default     = null
}
variable "cluster_name" {
  type    = string
  default = "cncfoci"
}
variable "kube_apiserver_domain" {
  type    = string
  default = "kube-cncfoci.sharing.io"
}
variable "cidr_blocks" {
  type    = string
  default = "10.0.0.0/16"
}
variable "subnet_block" {
  type    = string
  default = "10.0.0.0/24"
}
variable "compartment_id" {
  type     = string
  nullable = false
}
variable "talos_version" {
  type    = string
  default = "v1.7.5"
}
variable "kubernetes_version" {
  type    = string
  default = "v1.30.0"
}
variable "instance_shape" {
  default = "VM.Standard.A1.Flex"
}
