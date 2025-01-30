# Create ECR repositories
resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repository_names)

  name = "${var.environment}-${each.value}"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Lifecycle policy for each repository
resource "aws_ecr_lifecycle_policy" "policy" {
  for_each = aws_ecr_repository.repos

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.image_retention_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Repository Policy
resource "aws_ecr_repository_policy" "policy" {
  for_each = aws_ecr_repository.repos

  repository = each.value.name
  policy     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromEKS"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# Data source for AWS account ID
data "aws_caller_identity" "current" {}

