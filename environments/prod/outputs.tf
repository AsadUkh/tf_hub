# environments/prod/outputs.tf

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "cluster_certificate_authority" {
  value       = module.eks.cluster_ca_certificate
  description = "EKS cluster certificate authority data"
  sensitive   = true
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS instance endpoint"
}

output "redis_endpoint" {
  value       = module.redis.redis_endpoint
  description = "Redis endpoint"
}

output "hosted_zone_ids" {
  value       = module.externaldns.hosted_zone_ids
  description = "Map of domain names to hosted zone IDs"
}

output "certificate_arn" {
  value       = module.certificates.certificate_arn
  description = "ACM certificate ARN"
}

output "argocd_url" {
  value       = module.argocd.argocd_url
  description = "ArgoCD URL"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "ecr_repository_urls" {
  value       = module.ecr.repository_urls
  description = "ECR repository URLs"
}