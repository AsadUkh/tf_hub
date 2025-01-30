# environments/prod/terraform.tfvars

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

ondemand_machine_type = "n2-standard-8"
spot_machine_type     = "n2-standard-8"

gke_node_capacity = {
  on_demand = {
    min = 0
    max = 4

  }
  spot = {
    min = 0
    max = 2
  }
}

cloud_sql_instance_configuration = {
  database_version       = "POSTGRES_15"
  backup_enabled         = true
  rds_instance_class     = "db-custom-2-7680"
  retained_backups_count = 30
  availability_type      = "REGIONAL"
  deletion_protection    = false
}

databases = {
  "prod_db" = {
    name     = "prod_db"
    username = "prod_user"
  }
}

github_repositories = {
  snz-backend-service = {
    artifactory_format = "docker"
    artifactory_name   = "backend-api"
  }
  github_repo2_name = {
    artifactory_format = "docker"
    artifactory_name   = "frontend-app"
  }
}

redis_configuration = {
  tier               = "STANDARD_HA"
  memory_size_gb     = 5
  redis_version      = "REDIS_7_0"
  replica_count      = 2
  read_replicas_mode = "READ_REPLICAS_ENABLED"
}


ingress_hosts = [
  {
    host         = "snz-backend-service.prod.nylabank.com"
    path         = "/"
    backend_name = "snz-backend-service"
    port         = 3000
  },
  {
    host         = "nginx-1.prod.nylabank.com"
    path         = "/"
    backend_name = "nginx"
    port         = 80
  },
  {
    host         = "javaapp-1.prod.nylabank.com"
    path         = "/"
    backend_name = "javademo"
    port         = 8181
  },
  {
    host         = "wishlist.prod.nylabank.com"
    path         = "/wishlist"
    backend_name = "wishlist-service"
    port         = 8080
  },
  {
    host         = "wishlist-products.prod.nylabank.com"
    path         = "/products"
    backend_name = "wishlist-service"
    port         = 8081
  },
  {
    host         = "wishlist-login.prod.nylabank.com"
    path         = "/login"
    backend_name = "wishlist-service"
    port         = 8082
  }
]
