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


