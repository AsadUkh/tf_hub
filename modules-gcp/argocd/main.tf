# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      environment = var.environment
    }
  }
}

# Deploy ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.46.7"
  force_update = true
  upgrade_install = true

  values = [
    file("${path.module}/values.yaml")
  ]
  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.controller"
    value = "generic"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "server.ingress.hostname"
    value = "argocd.prod.nylabank.com"
  }

  set {
    name  = "server.ingress.annotations.kubernetes.io/server.ingress.class"
    value = "nginx"
  }

#   set {
#     name  = "server.ingress.hosts[0]"
#     value = "argocd.prod.nylabank.com"
#   }

  depends_on = [
    kubernetes_namespace.argocd
  ]
}
