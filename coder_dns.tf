resource "powerdns_zone" "coder" {
  name        = "coder.${var.domain}."
  kind        = "Native"
  nameservers = ["ns1.sharing.io.", "ns2.sharing.io."]
}
resource "powerdns_record" "coder-A" {
  zone       = "coder.${var.domain}."
  name       = "coder.${var.domain}."
  type       = "A"
  ttl        = 300
  records    = [module.cluster.cluster_ingress_ip]
  depends_on = [powerdns_zone.coder]
}
resource "powerdns_record" "coder-WILDCARD" {
  zone       = "coder.${var.domain}."
  name       = "*.coder.${var.domain}."
  type       = "A"
  ttl        = 300
  records    = [module.cluster.cluster_ingress_ip]
  depends_on = [powerdns_zone.coder]
}
