provider "kubernetes" {
  host                   = "https://${module.cluster-east1.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster-east1.ca_cert)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = module.cluster-east1.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.cluster-east1.ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }

}

