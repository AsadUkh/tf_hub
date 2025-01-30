
terraform {

  backend "gcs" {
    bucket  = "tf-state-nylabank-prod"
    prefix  = "prod/terraform.tfstate" 
  }

  required_providers {
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "~> 2.0"
        }
        helm = {
          source  = "hashicorp/helm"
          version = "~> 2.0"
        }
   }
  
}

provider "google" {
#   impersonate_service_account = "project-factory@mtech-cloudservices-prj.iam.gserviceaccount.com"
  project                     = var.project_id
}
provider "google-beta" {
#   impersonate_service_account = "project-factory@mtech-cloudservices-prj.iam.gserviceaccount.com"
  project                     = var.project_id
}