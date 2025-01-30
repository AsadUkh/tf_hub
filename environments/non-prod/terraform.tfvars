# VPC Configuration
vpc_cidr = "192.168.0.0/16"
azs      = ["us-east-1a", "us-east-1b"]

# EKS Configuration
cluster_version = "1.31"
eks_node_instance_types = {
  on_demand = ["t3.medium"]
  spot      = ["t3.medium", "t3.large"]
}
eks_node_capacity = {
  on_demand = {
    min     = 0
    max     = 0
    desired = 0
  }
  spot = {
    min     = 2
    max     = 4
    desired = 2
  }
}

# RDS Configuration
rds_instance_class    = "t3.small"
rds_allocated_storage = 50
rds_engine_version    = "15.7"
rds_backup_retention  = 1
rds_multi_az         = false

# General Configuration
project = "nylabank"

# Domain Configuration
domain_names = [
  "dev.nylabank.com",
  "uat.nylabank.com"
]

# ArgoCD Configuration
argocd_admin_password = "P@ssw0rd"

# Monitoring Configuration
prometheus_retention_days = 15
grafana_admin_password   = "P@ssw0rd"

# Resource Limits
pod_cpu_limit      = "2"
pod_memory_limit   = "4Gi"
pod_cpu_request    = "200m"
pod_memory_request = "512Mi"

# Alert Thresholds
cpu_threshold_percent    = 80
memory_threshold_percent = 80
disk_threshold_percent   = 80

# Backup Configuration
backup_enabled  = true
backup_schedule = "0 2 * * *"  # 2 AM daily

ecr_repository_names = [
  "backend-api",
  "frontend-app"
]

databases = {
  dev = {
    name     = "devdb"
    username = "dev_user"
  }
  uat = {
    name     = "uatdb"
    username = "uat_user"
  }
}