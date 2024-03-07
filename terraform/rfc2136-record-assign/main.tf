resource "dns_a_record_set" "record" {
  zone      = var.zone
  name      = var.name
  addresses = toset(var.addresses)
  ttl       = var.ttl
}
