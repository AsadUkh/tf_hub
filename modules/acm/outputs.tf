output "certificate_arn" {
  value       = aws_acm_certificate.main.arn
  description = "ARN of the issued certificate"
}

output "certificate_domain_validation_options" {
  value       = aws_acm_certificate.main.domain_validation_options
  description = "Domain validation options"
}
