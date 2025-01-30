# modules/acm/main.tf



locals {
  # Remove wildcard prefix for zone lookups
  domain_to_zone_map = {
    for domain in var.domain_names :
    domain => replace(domain, "*.", "")
  }
}

# Create the certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_names[0]
  subject_alternative_names = slice(var.domain_names, 1, length(var.domain_names))
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.environment}-certificate"
    Environment = var.environment
  }
}

# Create DNS records for validation
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      # Look up the zone ID using the base domain (without wildcard)
      zone_id = var.zone_ids[replace(dvo.domain_name, "*.", "")]
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# Validate the certificate
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

