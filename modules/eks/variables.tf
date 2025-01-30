variable "environment" {
  type        = string
  description = "Environment name (non-prod or prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet IDs"
}

variable "eks_nodes_security_group_id" {
  type        = string
  description = "Security group ID for EKS nodes"
}