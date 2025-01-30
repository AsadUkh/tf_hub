resource "google_artifact_registry_repository" "repos" {
  for_each = var.github_repositories

  repository_id = each.value.artifactory_name
  project       = var.project_id
  location      = var.region
  format        = each.value.artifactory_format

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}


resource "google_artifact_registry_repository_iam_binding" "gke_pull" {
  for_each   = google_artifact_registry_repository.repos
  project    = var.project_id
  location   = var.region
  repository = each.value.name
  role       = "roles/artifactregistry.reader"
  members    = ["serviceAccount:${var.gke_service_account}"]
}

resource "google_artifact_registry_repository_iam_binding" "github_push" {
  for_each   = google_artifact_registry_repository.repos
  project    = var.project_id
  location   = var.region
  repository = each.value.name
  role       = "roles/artifactregistry.writer"
  members    = ["serviceAccount:${google_service_account.github_actions.email}"]
}

resource "google_service_account" "github_actions" {
  account_id   = var.github_service_account_name
  display_name = "GitHub Actions Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "github_impersonation" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  display_name              = "GitHub Actions Pool"
  workload_identity_pool_id = "githubactions-pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  depends_on = [google_iam_workload_identity_pool.github_pool]

  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  project                            = var.project_id
  display_name                       = "GitHub Actions Provider"

  attribute_condition = "assertion.repository_owner == 'nylabank'"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.aud"              = "assertion.aud"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_workload_identity_binding" {
  for_each           = var.github_repositories
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/40089388371/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/attribute.repository/nylabank/${each.key}"
}

