resource "google_compute_firewall" "redis_firewall" {
  name    = "${var.environment}-redis-firewall"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  direction          = "INGRESS"
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = ["0.0.0.0/0"]

  priority    = 1000
  disabled    = false
  description = "Allow ingress traffic to Redis on port 6379"
}

resource "google_compute_firewall" "redis_egress_firewall" {
  name    = "${var.environment}-redis-egress-firewall"
  network = var.network_name

  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = ["0.0.0.0/0"]
  priority           = 1000
  disabled           = false

  description = "Allow egress traffic from Redis to all destinations"
}


resource "google_redis_instance" "redis" {
  name               = "${var.environment}-redis"
  tier               = var.redis_configuration.tier
  memory_size_gb     = var.redis_configuration.memory_size_gb
  region             = var.region
  redis_version      = var.redis_configuration.redis_version
  project            = var.project_id
  replica_count      = var.redis_configuration.replica_count
  read_replicas_mode = var.redis_configuration.read_replicas_mode

  redis_configs = {
    "maxmemory-policy" = "allkeys-lru"
  }

  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 5
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  persistence_config {
    persistence_mode    = "RDB"
    rdb_snapshot_period = "TWELVE_HOURS"
  }

  authorized_network = var.network_name
}


output "redis_instance_name" {
  value = google_redis_instance.redis.name
}

output "redis_instance_host" {
  value = google_redis_instance.redis.host
}
