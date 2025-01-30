# Generate master password
resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_nodes_security_group_id]
  }

  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment}-rds"
  subnet_ids = var.private_subnets

  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
  }
}

# Master credentials secret
resource "aws_secretsmanager_secret" "db_master_credentials" {
  name = "${var.environment}-rds-master-credentials"
  
  tags = {
    Environment = var.environment
    Type        = "master"
  }
}

resource "aws_secretsmanager_secret_version" "db_master_credentials" {
  secret_id = aws_secretsmanager_secret.db_master_credentials.id
  secret_string = jsonencode({
    username = "postgresadmin"
    password = random_password.master_password.result
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    database = "postgres"
  })

  depends_on = [aws_db_instance.postgres]
}

# RDS instance
resource "aws_db_instance" "postgres" {
  identifier        = "${var.environment}-postgres"
  engine            = "postgres"
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  
  db_name  = "postgres"
  username = "postgresadmin"
  password = random_password.master_password.result

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.rds_backup_retention
  multi_az               = var.rds_multi_az

  skip_final_snapshot    = true

  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
  }
}

# Database user passwords
resource "random_password" "db_passwords" {
  for_each = var.databases

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Database credentials secrets
resource "aws_secretsmanager_secret" "db_credentials" {
  for_each = var.databases

  name = "${var.environment}-${each.value.name}-credentials"
  
  tags = {
    Environment = var.environment
    Database    = each.value.name
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  for_each = var.databases

  secret_id = aws_secretsmanager_secret.db_credentials[each.key].id
  secret_string = jsonencode({
    username = each.value.username
    password = random_password.db_passwords[each.key].result
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    database = each.value.name
  })
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
      -h ${aws_db_instance.postgres.address} \
      -p ${aws_db_instance.postgres.port} \
      -U postgresadmin \
      -d postgres \
      -c 'CREATE DATABASE ${each.value.name};' \
      -c 'CREATE USER ${each.value.username} WITH ENCRYPTED PASSWORD '\''${random_password.db_passwords[each.key].result}'\'';' \
      -c 'GRANT ALL PRIVILEGES ON DATABASE ${each.value.name} TO ${each.value.username};' \
      -c 'ALTER DATABASE ${each.value.name} OWNER TO ${each.value.username};'
    EOF
  }

  depends_on = [
    aws_db_instance.postgres,
    aws_secretsmanager_secret_version.db_credentials
  ]
}