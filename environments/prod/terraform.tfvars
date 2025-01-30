# environments/prod/terraform.tfvars

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EKS Configuration
cluster_version = "1.31"
eks_node_instance_types = {
  on_demand = ["t3.medium"]
  spot      = ["t3.medium", "t3.large"]
}
eks_node_capacity = {
  on_demand = {
    min     = 3
    max     = 6
    desired = 3
  }
  spot = {
    min     = 3
    max     = 6
    desired = 3
  }
}

# RDS Configuration
rds_instance_class    = "t3.medium"
rds_allocated_storage = 100
rds_engine_version    = "15.7"
rds_backup_retention  = 30

# Redis Configuration
redis_node_type       = "cache.t3.medium"
redis_num_cache_nodes = 1

# Domain Configuration
domain_names = [
  "nylabank.com"
]

# ArgoCD Configuration
argocd_admin_password = "change-me-and-store-in-secrets-manager"

# Backup Configuration
backup_enabled  = true
backup_schedule = "0 1 * * *"  # 1 AM daily

# Resource Limits
pod_cpu_limit      = "4"
pod_memory_limit   = "8Gi"
pod_cpu_request    = "500m"
pod_memory_request = "1Gi"

# Alert Thresholds
cpu_threshold_percent    = 75
memory_threshold_percent = 75
disk_threshold_percent   = 75