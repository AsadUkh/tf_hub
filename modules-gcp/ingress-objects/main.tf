resource "kubernetes_ingress_v1" "multi_host_ingress" {
  metadata {
    name      = var.ingress_name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"               = "gce"
      "ingress.gcp.kubernetes.io/pre-shared-cert" = "nylabank-prd-wc-cert"
      "cloud.google.com/neg"                      = "{\"ingress\": true}"
      "external-dns.alpha.kubernetes.io/hostname" = join(",", [for host in var.ingress_hosts : host.host])
    }
  }



  spec {
    ingress_class_name = "gce"
    dynamic "rule" {
      for_each = var.ingress_hosts
      content {
        host = rule.value.host
        http {
          path {
            path = rule.value.path
            backend {
              service {
                name = rule.value.backend_name
                port {
                  number = rule.value.port
                }
              }
            }
          }
        }
      }
    }
  }
}