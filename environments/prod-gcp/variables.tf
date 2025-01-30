# environments/prod/variables.tf

# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "project_id" {
  type        = string
  description = "GCP Project Name"
  default     = "nylabank-prod"
}

variable "region" {
  type        = string
  description = "GCP Project Name"
  default     = "us-east1"
}

# EKS Variables
variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "argocd_admin_password" {
  type        = string
  description = "ArgoCD admin password"
  sensitive   = true
  default     = "change-me-and-store-in-secrets-manager"
}

variable "ondemand_machine_type" {
  type = string
}

variable "spot_machine_type" {
  type = string
}

variable "gke_node_capacity" {
  description = "Defines the minimum and maximum node capacity for on-demand and spot node pools."
  type = object({
    on_demand = object({
      min = number
      max = number
    })
    spot = object({
      min = number
      max = number
    })
  })
}


variable "cloud_sql_instance_configuration" {
  description = "Configuration settings for the Cloud SQL instance."
  type = object({
    database_version       = string
    backup_enabled         = bool
    rds_instance_class     = string
    retained_backups_count = number
    availability_type      = string
    deletion_protection    = bool
  })
}

variable "databases" {
  description = "A map of databases with their usernames"
  type = map(object({
    name     = string
    username = string
  }))
}

variable "github_repositories" {
  description = "A map of GitHub repositories with their respective Artifactory configurations"
  type = map(object({
    artifactory_format = string
    artifactory_name   = string
  }))
}


variable "redis_configuration" {
  description = "Configuration for the Redis instance"
  type = object({
    tier               = string
    memory_size_gb     = number
    redis_version      = string
    replica_count      = number
    read_replicas_mode = string
  })
}

variable "ingress_hosts" {
  type = list(object({
    host         = string
    path         = string
    backend_name = string
    port         = number
  }))
}