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

variable "private_subnetwork_name" {
  type        = string
  description = "Subnetwork for cluster to be provisioned"
}

variable "environment" {
  type        = string
  description = "Environment name (non-prod or prod)"
}

variable "secondary_ip_range_names_pod" {
  type = string

}
variable "secondary_ip_range_names_svc" {
  type = string
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