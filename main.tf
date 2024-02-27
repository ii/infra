module "cloudnative-coop" {
  source = "./clusters/cloudnative.coop/terraform"

  equinix_metal_project_id = var.equinix_metal_project_id

  providers = {
    talos   = talos
    helm    = helm
    equinix = equinix
  }
}
