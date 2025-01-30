# modules/monitoring/main.tf


# Prometheus Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      environment = var.environment
    }
  }
}

# Prometheus ServiceAccount
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
}

# Prometheus Storage Class
resource "kubernetes_storage_class" "prometheus" {
  metadata {
    name = "prometheus-storage"
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy     = "Retain"
  parameters = {
    type = "gp3"
  }
}

# Prometheus PVC
resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name      = "prometheus-storage"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.prometheus.metadata[0].name
  }
}

# Helm release for Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      server: {
        persistentVolume: {
          existingClaim: kubernetes_persistent_volume_claim.prometheus.metadata[0].name
        }
      }
    })
  ]
}

# Helm release for Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      persistence: {
        enabled: true
        size: "10Gi"
      }
      datasources: {
        "datasources.yaml": {
          apiVersion: 1
          datasources: [
            {
              name: "Prometheus"
              type: "prometheus"
              url: "http://prometheus-server"
              access: "proxy"
              isDefault: true
            }
          ]
        }
      }
    })
  ]
}

