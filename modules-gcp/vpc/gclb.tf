# module "classic-gclb" {
#   source  = "GoogleCloudPlatform/lb-http/google//modules/dynamic_backends"
#   version = "12.0.0"

#   name                = "nylabank-gclb"
#   project             = var.project_id
#   enable_ipv6         = false
#   create_ipv6_address = false
#   http_forward        = true
#   #   create_http_forward = true

#   create_address = false
#   address        = google_compute_global_address.external-gclb.address

#   load_balancing_scheme = "EXTERNAL"
#   firewall_networks     = [ var.vpc_name]
#   firewall_projects     = [var.project_id]

#   ssl = false

#   https_redirect   = false
#   ssl_certificates = []

#   #   ssl_policy = google_compute_ssl_policy.ecom-ssl-policy.self_link

#   url_map        = google_compute_url_map.gcp_external_classic_urlmap.self_link
#   create_url_map = false


#   #   security_policy = "https://www.googleapis.com/compute/beta/projects/mtech-ns-ecom-perf/global/securityPolicies/ecom-trans-perf-ca"

#   backends = {
#     nginx-be = {
#       protocol   = "HTTP"
#       port_name  = "http"
#       enable_cdn = false
#       health_check = {
#         request_path = "/"
#         port         = "80"
#         host         = "nginx.prod.nylabank.com"

#       }
#       log_config = {
#         enable      = false
#         sample_rate = 1.0
#       }
#       groups = [
#         {
#           group           = data.google_compute_network_endpoint_group.east1d_neg.id
#           capacity_scaler = 1
#           balancing_mode  = "RATE"
#           max_rate        = "1.0"
#         },
#            {
#           group           = data.google_compute_network_endpoint_group.east1c_neg.id
#           capacity_scaler = 1
#           balancing_mode  = "RATE"
#           max_rate        = "1.0"
#         }
#       ]
#       iap_config = {
#         enable = false
#       }
#     },
#     argocd-be = {
#       protocol   = "HTTP"
#       port_name  = "http"
#       enable_cdn = false
#       health_check = {
#         request_path = "/healthz?full=true"
#         port         = "80"
#         host         = "argocd.prod.nylabank.com"

#       }
#       log_config = {
#         enable      = false
#         sample_rate = 1.0
#       }
#       groups = [
#         {
#           group           = data.google_compute_network_endpoint_group.east1d_neg.id
#           capacity_scaler = 1
#           balancing_mode  = "RATE"
#           max_rate        = "1.0"
#         },
#            {
#           group           = data.google_compute_network_endpoint_group.east1c_neg.id
#           capacity_scaler = 1
#           balancing_mode  = "RATE"
#           max_rate        = "1.0"
#         }
#       ]
#       iap_config = {
#         enable = false
#       }
#     }
#   }
# }


# resource "google_compute_backend_bucket" "gcp-dummy-fail-no-host-header" {
#   bucket_name = google_storage_bucket.dummy_backend_bucket.name
#   enable_cdn  = false
#   name        = "gcp-dummy-fail-no-host-header"
#   project     = var.project_id
# }

# resource "google_compute_url_map" "gcp_external_classic_urlmap" {
#   name            = "gcp-classic-gclb"
#   description     = "mcom ns perf external url map"
#   default_service = google_compute_backend_bucket.gcp-dummy-fail-no-host-header.self_link

#   host_rule {
#     hosts        = ["nginx.prod.nylabank.com"]
#     path_matcher = "nginx"
#   }

#   path_matcher {
#     default_service = module.classic-gclb.backend_services["nginx-be"].self_link
#     description     = null
#     name            = "nginx"
#   }

#   host_rule {
#     hosts        = ["argocd.prod.nylabank.com"]
#     path_matcher = "argocd"
#   }

#   path_matcher {
#     default_service = module.classic-gclb.backend_services["argocd-be"].self_link
#     description     = null
#     name            = "argocd"
#   }
# }


# resource "google_compute_global_address" "external-gclb" {
#   ip_version   = "IPV4"
#   address_type = "EXTERNAL"
#   name         = "external-gclb"
#   project      = var.project_id
# }

# resource "google_storage_bucket" "dummy_backend_bucket" {
#   location      = "US"
#   name          = format("%s-dummy-backend-bucket", var.project_id)
#   storage_class = "MULTI_REGIONAL"
# }

# data "google_compute_network_endpoint_group" "east1d_neg" {
#     name="k8s1-40ac2237-ingress-ngi-ingress-ingress-nginx-cont-8-733d485c"
#     zone="us-east1-d"
# }

# data "google_compute_network_endpoint_group" "east1c_neg" {
#     name="k8s1-40ac2237-ingress-ngi-ingress-ingress-nginx-cont-8-733d485c"
#     zone="us-east1-c"
# }