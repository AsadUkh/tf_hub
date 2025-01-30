variable "environment" {
  type        = string
  description = "Environment name"
}

variable "domain_names" {
  type        = list(string)
  description = "List of domain names for the certificate"
}

variable "zone_ids" {
  type        = map(string)
  description = "Map of domain names to their Route53 zone IDs"
}