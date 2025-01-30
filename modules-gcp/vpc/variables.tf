variable "environment" {
  type        = string
  description = "Environment name (non-prod or prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "project_id" {
  type        = string
  description = "GCP Project Name"
  default     = "nylabank-prod"
}


variable "vpc_name" {
  type        = string
  description = "GCP Project Name"
  default     = "nylabank-vpc-prod"
}


variable "region" {
  type        = string
  description = "GCP Project Name"
  default     = "us-east1"
}


