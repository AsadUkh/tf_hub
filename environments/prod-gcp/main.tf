module "vpc" {
  source = "../../modules-gcp/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

output "secondary_ip_range_names" {
  value = tomap({
    for subnet_name, ranges in module.vpc.subnets_secondary_ranges :
    subnet_name => [for range in ranges : range["range_name"]]
  })
}

module "cluster-east1" {
  source                       = "../../modules-gcp/gke"
  project_id                   = var.project_id
  region                       = var.region
  network_name                 = module.vpc.network_name
  private_subnetwork_name      = module.vpc.private_subnetwork_name
  environment                  = var.environment
  ondemand_machine_type        = var.ondemand_machine_type
  spot_machine_type            = var.spot_machine_type
  secondary_ip_range_names_pod = module.vpc.secondary_ip_range_names["0"][0]
  secondary_ip_range_names_svc = module.vpc.secondary_ip_range_names["0"][1]
  gke_node_capacity            = var.gke_node_capacity
}

module "cloudsql" {

  source                           = "../../modules-gcp/cloud-sql"
  region                           = var.region
  environment                      = var.environment
  project_id                       = var.project_id
  network_name                     = module.vpc.network_name
  cloud_sql_instance_configuration = var.cloud_sql_instance_configuration
  databases                        = var.databases

}
data "google_service_account" "gke_service_account" {
  account_id = "tf-gke-nylabank-prod-e-ko9l"
  project    = var.project_id
}

module "gar" {
  source = "../../modules-gcp/gar"

  environment                 = var.environment
  github_repositories         = var.github_repositories
  image_retention_count       = 50
  project_id                  = var.project_id
  region                      = "us"
  gke_service_account         = data.google_service_account.gke_service_account.email
  github_service_account_name = "github-actions-sa"
}

module "memstore" {
  source              = "../../modules-gcp/memstore"
  project_id          = var.project_id
  region              = var.region
  network_name        = module.vpc.network_name
  environment         = var.environment
  redis_configuration = var.redis_configuration
}

module "argocd" {
  source = "../../modules-gcp/argocd"

  environment    = var.environment
  cluster_name   = module.cluster-east1.cluster_name
  admin_password = var.argocd_admin_password
}

module "externaldns" {
  source              = "../../modules-gcp/externaldns"
  gke_service_account = "tf-gke-nylabank-prod-e-ko9l@nylabank-prod.iam.gserviceaccount.com"
}

module "ingress" {
  source = "../../modules-gcp/ingress"

  environment = var.environment
}

// workload identity for apps if they want to use gcp resources
resource "google_service_account" "apps_sa" {
  account_id = "snz-backend-service"
  project    = var.project_id
}
resource "google_service_account_iam_member" "apps_sa_wi" {
  service_account_id = google_service_account.apps_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:nylabank-prod.svc.id.goog[apps/snz-backend-service]"
}

resource "google_project_iam_member" "secret_manager" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.apps_sa.email}"
}

module "ingress-objects" {
  source        = "../../modules-gcp/ingress-objects"
  ingress_hosts = var.ingress_hosts
}