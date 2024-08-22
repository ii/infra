terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.7.0" # TODO include version in project root providers
    }
  }
  required_version = ">= 1.2"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}
