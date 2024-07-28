terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      # version = "^6.4.0" # TODO include version in project root providers
    }
  }
  required_version = ">= 1.2"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.key_file
  region           = var.region
}
