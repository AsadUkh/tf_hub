output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS instance endpoint"
}

output "rds_secret_arn" {
  value       = aws_secretsmanager_secret.db_master_credentials.arn
  description = "ARN of the master credentials secret"
  sensitive   = true
}

output "database_secrets" {
  value = {
    for db_name, db in var.databases : db_name => {
      arn      = aws_secretsmanager_secret.db_credentials[db_name].arn
      endpoint = "${aws_db_instance.postgres.endpoint}/${db.name}"
    }
  }
  description = "Map of database names to their secret ARNs"
  sensitive   = true
}