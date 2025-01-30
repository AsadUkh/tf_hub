resource "google_dns_managed_zone" "nylabank_com" {
  name        = var.zone_name
  dns_name    = "prod.nylabank.com."
  description = "Automatically managed zone by kubernetes.io/external-dns"

  dnssec_config {
    state = "on"
  }
}

variable "gke-project" {
  type        = string
  description = "Name of the project that the GKE cluster exists in"
  default     = "nylabank-prod"
}

variable "ksa_name" {
  type        = string
  description = "Name of the Kubernetes service account that will be accessing the DNS Zones"
  default     = "external-dns"
}

variable "kns_name" {
  type        = string
  description = "Name of the Kubernetes Namespace"
  default     = "external-dns"
}

data "google_project" "project" {
  project_id = var.gke-project
}

locals {
  member = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.gke-project}.svc.id.goog/subject/ns/${var.kns_name}/sa/${var.ksa_name}"
}

resource "google_project_iam_member" "external_dns" {
  member  = local.member
  project = var.project_id
  role    = "roles/dns.reader"
}

resource "google_dns_managed_zone_iam_member" "member" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.nylabank_com.name
  role         = "roles/dns.admin"
  member       = local.member
}

resource "google_project_iam_member" "gke_serivce_account_permission_to_dns" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${var.gke_service_account}"
}

resource "google_service_account" "external_dns_gcp_sa" {
  account_id   = "sa-edns"                      
  display_name = "external-dns service acocunt"       
}

resource "google_project_iam_member" "dns_admin_role" {
  project = var.project_id  
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns_gcp_sa.email}"
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.external_dns_gcp_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:nylabank-prod.svc.id.goog[external-dns/external-dns]"
depends_on = [
    kubernetes_service_account.external_dns
  ]
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "external-dns"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.external_dns_gcp_sa.email
    }
  }
    depends_on = [
    kubernetes_namespace.external_dns
  ]
}


# Helm Release for ExternalDNS
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "external-dns"
  version    = "1.13.0"

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    kubernetes_service_account.external_dns
  ]
}

