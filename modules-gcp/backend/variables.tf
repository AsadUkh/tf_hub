variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the bucket"
  type        = string
  default     = "us-east1"
}

variable "backend_names" {
  description = "List of backend GCS bucket names to create"
  type        = list(string)
}

variable "retention_period_days" {
  description = "Number of days to retain state files before deletion"
  type        = number
  default     = 90
}

# variable "admin_email" {
#   description = "Admin email to grant storage object admin access"
#   type        = string
# }

variable "use_kms_key" {
  description = "Flag to enable Cloud KMS encryption for the bucket"
  type        = bool
  default     = false
}

variable "kms_key_ring_name" {
  description = "Name of the KMS key ring (if using KMS encryption)"
  type        = string
  default     = "terraform-key-ring"
}


variable "kms_key_name" {
  description = "Name of the KMS key (if using KMS encryption)"
  type        = string
  default     = "terraform-state-key"
}

variable "kms_key_ring_location" {
  description = "Location of the KMS key ring"
  type        = string
  default     = "us"
}

variable "kms_key" {
  description = "Fully qualified KMS key name for bucket encryption (if pre-existing key is used)"
  type        = string
  default     = null
}
