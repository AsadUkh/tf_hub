output "admin_role_arn" {
  value = kubernetes_cluster_role.admin.metadata[0].name
}

output "developer_role_arn" {
  value = kubernetes_cluster_role.developer.metadata[0].name
}

output "viewer_role_arn" {
  value = kubernetes_cluster_role.viewer.metadata[0].name
}