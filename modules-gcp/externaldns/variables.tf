
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default = "nylabank-prod"
}


variable "gke_service_account" {
  description = "GCP Project ID"
  type        = string
  default = "gke_service_account"
}


variable "zone_name" {
  description = "GCP DNS Zone name"
  type        = string
  default = "prod-nylabank-com"
}
