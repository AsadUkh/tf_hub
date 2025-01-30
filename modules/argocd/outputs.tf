output "argocd_url" {
  value = "${var.environment == "prod" ? "argocd" : "argocd-${var.environment}"}.nylabank.com"
}