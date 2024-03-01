variable "zone" {
  description = "the DNS zone"
  type        = string
  default     = ""
}
variable "name" {
  description = "the DNS record name"
  type        = string
  default     = ""
}
variable "addresses" {
  description = "the DNS record addresses"
  type        = list(string)
  default     = []
}
variable "ttl" {
  description = "the DNS record ttl"
  type        = number
  default     = 60
}
