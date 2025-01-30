variable "environment" {
  type        = string
  description = "Environment name"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "admin_password" {
  type        = string
  description = "ArgoCD admin password"
  sensitive   = true
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use"
}
