variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "eks_nodes_security_group_id" {
  type        = string
  description = "Security group ID for EKS nodes"
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance class"
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
  description = "Enable multi-AZ deployment"
  default     = false
}

variable "databases" {
  type = map(object({
    name     = string
    username = string
  }))
  description = "Map of databases to create in RDS instance"
  default     = {}
}