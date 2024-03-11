locals {
  # NOTE ipxe_script_url must be not contain extensions and must contain the following kernel args
  #   console=ttyS1,115200n8  talos.platform=equinixMetal
  ipxe_script_url = "https://pxe.factory.talos.dev/pxe/32b31bd7a77a4c38529e38125c50282ae481723f25aa911c4c8a658638fe16d0/v1.6.6/metal-amd64"
  # NOTE install image must contain the following kernel args
  #   console=ttyS1,115200n8  talos.platform=equinixMetal
  talos_install_image = "factory.talos.dev/installer/04e08b65e14d351ab85789fd0b0d73705a29397288ec0b77a13e9dd0ea18d08b:v1.6.6"
  talos_version       = "v1.6.6"
  kubernetes_version  = "v1.29.2"
  metro               = "sv"
}
