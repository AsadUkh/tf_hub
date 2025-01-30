
data "google_client_config" "default" {}

# # provider "kubernetes" {
# #   host                   = "https://${module.gke.endpoint}"
# #   token                  = data.google_client_config.default.access_token
# #   cluster_ca_certificate = base64decode(module.gke.ca_certificate)
# # }



// to do node autopriovsioning
// Control plane access using IPv4 addresses disabled, add autohrized netewrks ,security  bindar auth, secret manager


module "proc-east1" {
  source     = "terraform-google-modules/kubernetes-engine/google"
  version    = "~> 35.0"
  project_id = var.project_id
  name       = "${var.project_id}-east1"
  region     = var.region
  # zones                      = ["us-central1-a", "us-central1-b", "us-central1-c"]
  network    = var.network_name
  subnetwork = var.private_subnetwork_name

  ip_range_pods               = var.secondary_ip_range_names_pod //"nylabank-vpc-prod-us-east1-private-subnet-1-pods"
  ip_range_services           = var.secondary_ip_range_names_svc //"nylabank-vpc-prod-us-east1-private-subnet-1-services"
  http_load_balancing         = true
  node_metadata               = "GKE_METADATA"
  enable_secret_manager_addon = true
  network_policy              = false
  horizontal_pod_autoscaling  = true
  monitoring_service          = "monitoring.googleapis.com/kubernetes"
  logging_service             = "logging.googleapis.com/kubernetes"
  filestore_csi_driver        = false
  dns_cache                   = false


  # Remove the default node pool
  remove_default_node_pool = true

  # Add custom node pools
  node_pools = [
    # On-demand instances node pool
    {
      name         = "on-demand-node-pool"
      machine_type = var.ondemand_machine_type
      # node_locations         = "us-central1-a,us-central1-b,us-central1-c"
      min_count              = var.gke_node_capacity.on_demand.min
      max_count              = var.gke_node_capacity.on_demand.max
      local_ssd_count        = 0
      spot                   = false
      disk_size_gb           = 100
      disk_type              = "pd-standard"
      image_type             = "COS_CONTAINERD"
      enable_gcfs            = false
      enable_gvnic           = false
      logging_variant        = "DEFAULT"
      auto_repair            = true
      auto_upgrade           = true
      create_service_account = true
      preemptible            = false
      initial_node_count     = 1
    },
    # Spot instances node pool
    {
      name         = "spot-node-pool"
      machine_type = var.spot_machine_type
      # node_locations         = "us-central1-a,us-central1-b,us-central1-c"
      min_count              = var.gke_node_capacity.spot.min
      max_count              = var.gke_node_capacity.spot.max
      local_ssd_count        = 0
      spot                   = true
      disk_size_gb           = 100
      disk_type              = "pd-standard"
      image_type             = "COS_CONTAINERD"
      enable_gcfs            = false
      enable_gvnic           = false
      logging_variant        = "DEFAULT"
      auto_repair            = true
      auto_upgrade           = true
      create_service_account = true
      # preemptible            = true
      initial_node_count = 1
    }
  ]

  # OAuth Scopes for all node pools
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  # Node pool labels
  node_pools_labels = {
    on-demand-node-pool = {
      node-type   = "on-demand",
      environment = var.environment
    }
    spot-node-pool = {
      node-type   = "spot",
      environment = var.environment
    }
  }




  # Node pool metadata
  node_pools_metadata = {
    on-demand-node-pool = {
      node-type   = "on-demand",
      environment = var.environment
    }
    spot-node-pool = {
      node-type   = "spot",
      environment = var.environment
    }
  }

  node_pools_taints = {
    all = []
  }


  node_pools_tags = {
    on-demand-node-pool = [
      "on-demand-node-pool", "${var.environment}"
    ]
    spot-node-pool = [
      "spot-node-pool", "${var.environment}"
    ]
  }
}


