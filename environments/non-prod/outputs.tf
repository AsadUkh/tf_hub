output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value     = module.eks.cluster_ca_certificate
  sensitive = true
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_secret_arn" {
  value     = module.rds.rds_secret_arn
  sensitive = true
}

output "database_secrets" {
  description = "Map of database secrets"
  value       = module.rds.database_secrets
  sensitive   = true
}

output "hosted_zone_ids" {  
  value = module.externaldns.hosted_zone_ids
}

output "name_servers" {
  value = module.externaldns.name_servers
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "ecr_repository_urls" {
  value       = module.ecr.repository_urls
  description = "ECR repository URLs"
}

output "database_endpoints" {
  description = "Database endpoints for each environment"
  value = {
    dev = "${module.rds.rds_endpoint}/devdb"
    uat = "${module.rds.rds_endpoint}/uatdb"
  }
}


output "database_secret_arns" {
  description = "Map of database secret ARNs"
  value = {
    for name, secret in module.rds.database_secrets : name => secret.arn
  }
  sensitive = true
}