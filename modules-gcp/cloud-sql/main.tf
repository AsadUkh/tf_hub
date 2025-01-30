
resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "google_compute_firewall" "postgres" {
  name    = "${var.environment}-postgres"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["env-prod"]


}


resource "google_sql_database_instance" "postgres" {
  name             = "${var.environment}-postgres"
  region           = var.region
  project          = var.project_id
  database_version = var.cloud_sql_instance_configuration.database_version

  settings {
    user_labels = {
      env = "prod"
    }
    tier = var.rds_instance_class
    backup_configuration {
      enabled = var.cloud_sql_instance_configuration.backup_enabled

      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = var.cloud_sql_instance_configuration.retained_backups_count
      }
    }
    availability_type = var.cloud_sql_instance_configuration.availability_type # Multi-AZ equivalent
  }

  root_password       = random_password.master_password.result
  deletion_protection = var.cloud_sql_instance_configuration.deletion_protection



}

# Create secret for master credentials in Google Secret Manager
resource "google_secret_manager_secret" "db_master_credentials" {
  secret_id = "${var.environment}-postgres-master-credentials"
  replication {
    auto {}
  }
  project = var.project_id

}

resource "google_secret_manager_secret_version" "db_master_credentials" {
  secret = google_secret_manager_secret.db_master_credentials.id
  secret_data = jsonencode({
    username = "postgres"
    password = random_password.master_password.result
    host     = google_sql_database_instance.postgres.ip_address[0].ip_address
    port     = "5432"
    database = "postgres"
  })
}

resource "random_password" "db_passwords" {
  for_each = var.databases

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create secrets for database credentials in Google Secret Manager
resource "google_secret_manager_secret" "db_credentials" {
  for_each  = var.databases
  secret_id = "${var.environment}-${each.value.name}-credentials"
  replication {
    auto {}
  }

  project = var.project_id
  #   project = var.project_id

}

resource "google_secret_manager_secret_version" "db_credentials" {
  for_each = var.databases

  secret = google_secret_manager_secret.db_credentials[each.key].id
  secret_data = jsonencode({
    username = each.value.username
    password = random_password.db_passwords[each.key].result
    host     = google_sql_database_instance.postgres.ip_address[0].ip_address
    port     = "5432"
    database = each.value.name
  })
}

resource "google_sql_database" "databases" {
  for_each = var.databases
  name     = each.value.name
  instance = google_sql_database_instance.postgres.name
}

# Create PostgreSQL User
resource "google_sql_user" "db_user" {
  for_each = var.databases
  name     = each.value.username
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_passwords[each.key].result
}



# Create databases and users
resource "null_resource" "create_databases" {
  for_each = var.databases

  triggers = {
    database_name = each.value.name
  }

  provisioner "local-exec" {
    command = <<-EOF
      PGPASSWORD='${random_password.master_password.result}' psql \
      -h ${google_sql_database_instance.postgres.ip_address[0].ip_address} \
      -p 5432 \
      -U postgres \
      -d postgres \
      -c 'GRANT ALL PRIVILEGES ON DATABASE ${each.value.name} TO ${each.value.username};' \
      -c 'GRANT ${each.value.username} TO postgres;' \
      -c 'ALTER DATABASE ${each.value.name} OWNER TO ${each.value.username};'
    EOF
  }

  depends_on = [
    google_sql_database_instance.postgres,
    google_secret_manager_secret_version.db_credentials
  ]
}


output "rds_endpoint" {
  value = google_sql_database_instance.postgres.ip_address
}