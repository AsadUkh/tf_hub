# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

# EKS Variables
variable "cluster_version" {
  type        = string
  description = "Kubernetes version for EKS cluster"
}

variable "eks_node_instance_types" {
  type = object({
    on_demand = list(string)
    spot      = list(string)
  })
  description = "Instance types for EKS node groups"
}

variable "eks_node_capacity" {
  type = object({
    on_demand = object({
      min     = number
      max     = number
      desired = number
    })
    spot = object({
      min     = number
      max     = number
      desired = number
    })
  })
  description = "Capacity configuration for EKS node groups"
}

# RDS Variables
variable "rds_instance_class" {
  type        = string
  description = "Instance class for RDS"
}

variable "rds_allocated_storage" {
  type        = number
  description = "Allocated storage for RDS in GB"
}

variable "rds_engine_version" {
  type        = string
  description = "PostgreSQL version for RDS"
}

variable "rds_backup_retention" {
  type        = number
  description = "Backup retention period in days"
}

variable "rds_multi_az" {
  type        = bool
  description = "Enable multi-AZ deployment for RDS"
  default     = false
}

# General Variables
variable "environment" {
  type        = string
  description = "Environment name"
  default     = "non-prod"
}

variable "project" {
  type        = string
  description = "Project name"
}

# Domain Configuration
variable "domain_names" {
  type        = list(string)
  description = "List of domain names to manage with ExternalDNS"
}

# ArgoCD Configuration
variable "argocd_admin_password" {
  type        = string
  description = "ArgoCD admin password"
  sensitive   = true
}

# Monitoring Configuration
variable "prometheus_retention_days" {
  type        = number
  description = "Prometheus data retention period in days"
  default     = 15
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  sensitive   = true
}

# Resource Limits
variable "pod_cpu_limit" {
  type        = string
  description = "Default CPU limit for pods"
  default     = "2"
}

variable "pod_memory_limit" {
  type        = string
  description = "Default memory limit for pods"
  default     = "4Gi"
}

variable "pod_cpu_request" {
  type        = string
  description = "Default CPU request for pods"
  default     = "200m"
}

variable "pod_memory_request" {
  type        = string
  description = "Default memory request for pods"
  default     = "512Mi"
}

# Alert Thresholds
variable "cpu_threshold_percent" {
  type        = number
  description = "CPU threshold percentage for alerts"
  default     = 80
}

variable "memory_threshold_percent" {
  type        = number
  description = "Memory threshold percentage for alerts"
  default     = 80
}

variable "disk_threshold_percent" {
  type        = number
  description = "Disk threshold percentage for alerts"
  default     = 80
}

# Backup Configuration
variable "backup_enabled" {
  type        = bool
  description = "Enable or disable backup"
  default     = true
}

variable "backup_schedule" {
  type        = string
  description = "Cron expression for backup schedule"
  default     = "0 2 * * *"  # 2 AM daily
}

variable "ecr_repository_names" {
  type        = list(string)
  description = "List of ECR repository names to create"
  default = [
    "backend-api",
    "frontend-app"
  ]
}

variable "databases" {
  type = map(object({
    name     = string
    username = string
  }))
  description = "Map of databases to create in RDS instance"
}
