# Outputs
output "repository_urls" {
  value = {
    for name, repo in aws_ecr_repository.repos : name => repo.repository_url
  }
  description = "Map of repository names to their URLs"
}

output "repository_arns" {
  value = {
    for name, repo in aws_ecr_repository.repos : name => repo.arn
  }
  description = "Map of repository names to their ARNs"
}