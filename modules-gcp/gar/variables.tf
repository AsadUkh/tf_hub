variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}



variable "image_retention_count" {
  description = "Number of images to retain"
  type        = number
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region or multi-region for the repositories (e.g., us, europe, asia)"
  type        = string
}

variable "gke_service_account" {
  description = "Service account for GKE nodes to pull images"
  type        = string
}

variable "github_service_account_name" {
  description = "Name of the service account for GitHub Actions"
  type        = string
  default     = "github-actions-sa"
}

variable "github_repositories" {
  description = "A map of GitHub repositories with their respective Artifactory configurations"
  type = map(object({
    artifactory_format = string
    artifactory_name   = string
  }))
}


# variable "github_repository" {
#   description = "GitHub repository (e.g., 'owner/repo')"
#   type        = string
# }