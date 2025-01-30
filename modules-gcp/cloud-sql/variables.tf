variable "environment" {
  description = "The environment name (e.g., production, staging)"
  type        = string

}

variable "region" {
  description = "The region for the GCP resources"
  type        = string
}

variable "project_id" {
  description = "The region for the GCP resources"
  type        = string
}

variable "network_name" {
  description = "The network name for the GCP resources"
  type        = string
}

variable "rds_instance_class" {
  description = "The instance class for the PostgreSQL instance"
  type        = string
  default     = "db-custom-2-7680"
}

# variable "rds_backup_retention" {
#   description = "The backup retention period for the PostgreSQL instance"
#   type        = number
# }

variable "databases" {
  description = "A map of databases with their usernames"
  type = map(object({
    name     = string
    username = string
  }))
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