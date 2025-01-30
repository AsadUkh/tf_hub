# Outputs
output "hosted_zone_ids" {
  description = "Map of domain names to their hosted zone IDs"
  value = {
    for domain, zone in data.aws_route53_zone.zones : domain => zone.zone_id
  }
}

output "name_servers" {
  description = "Map of domain names to their name servers"
  value = {
    for domain, zone in data.aws_route53_zone.zones : domain => zone.name_servers
  }
}

output "external_dns_role_arn" {
  description = "ARN of the IAM role used by ExternalDNS"
  value = aws_iam_role.external_dns.arn
}