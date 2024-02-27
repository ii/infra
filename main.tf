module "cloudnative-coop" {
  source = "./clusters/cloudnative.coop/terraform"

  equinix_metal_project_id = var.equinix_metal_project_id
  talos_version            = "v1.6.5"
  kubernetes_version       = "v1.29.2"
  ipxe_script_url          = "https://pxe.factory.talos.dev/pxe/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.6.5/metal-amd64"
  cluster_endpoint         = "https://145.40.90.158:6443"
  virtual_ip               = "145.40.90.158"

  providers = {
    talos   = talos
    helm    = helm
    equinix = equinix
  }
}
