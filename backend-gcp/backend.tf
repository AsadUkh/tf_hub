
terraform {

  backend "gcs" {
    bucket  = "tf-state-nylabank-prod"
    prefix  = "prod-shared-backends-state/terraform.tfstate" 
  }
}

provider "google" {

  project                     = var.project_id
}
provider "google-beta" {
  project                     = var.project_id
}