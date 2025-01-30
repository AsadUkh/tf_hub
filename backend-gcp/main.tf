module "backend_nyla_bank_prod" {
  source                = "../modules-gcp/backend/"
  backend_names         = ["tf-state-nylabank-prod"]
  retention_period_days = var.retention_period_days
  region                = var.region
  project_id            = var.project_id
  kms_key_ring_name     = var.kms_key_ring_name
  kms_key_name          = var.kms_key_name
}
