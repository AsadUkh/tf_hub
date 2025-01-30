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

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "retention_period_days" {
  type        = string
  description = "Environment name"
  default     = 90
}

variable "kms_key_ring_name" {
  description = "Name of the KMS key ring (if using KMS encryption)"
  type        = string
  default     = "nylabank-prod-key-ring"
}


variable "kms_key_name" {
  description = "Name of the KMS key (if using KMS encryption)"
  type        = string
  default     = "nylabank-prod-key"
}