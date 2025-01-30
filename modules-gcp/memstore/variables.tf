variable "region" {
  type        = string
  description = "GCP Project Name"
  default     = "us-east1"
}

variable "network_name" {
  type        = string
  description = "GCP Network name"
}

variable "project_id" {
  type        = string
  description = "GCP Project Name"
  default     = "nylabank-prod"
}

variable "environment" {
  type        = string
  description = "Environment name (non-prod or prod)"
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
