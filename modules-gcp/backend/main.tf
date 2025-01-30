

# Loop to create multiple GCS Buckets
resource "google_storage_bucket" "terraform_backends" {
  for_each = toset(var.backend_names)

  name    = each.value
  project = var.project_id
  location      = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.retention_period_days
    }
  }

  # Encryption using KMS key (optional)
  dynamic "encryption" {
    for_each = var.use_kms_key ? [1] : []
    content {
      default_kms_key_name = var.kms_key
    }
  }
}

# Loop to apply IAM roles to each bucket
# resource "google_storage_bucket_iam_member" "admin_access" {
#   for_each = google_storage_bucket.terraform_backends

#   bucket = each.value.name
#   role   = "roles/storage.objectAdmin"
#   member = "user:${var.admin_email}"
# }


resource "google_kms_key_ring" "terraform_key_ring" {
  count    = var.use_kms_key ? 1 : 0
  name     = var.kms_key_ring_name
  location = var.kms_key_ring_location
}

resource "google_kms_crypto_key" "terraform_key" {
  count    = var.use_kms_key ? 1 : 0
  name     = var.kms_key_name
  key_ring = google_kms_key_ring.terraform_key_ring[0].id
  purpose  = "ENCRYPT_DECRYPT"
}

output "bucket_names" {
  value = [for bucket in google_storage_bucket.terraform_backends : bucket.name]
}
