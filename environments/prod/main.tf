# environments/prod/main.tf

terraform {
  backend "s3" {
    bucket         = "nylabank-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

# Get AWS account ID
data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  environment                  = var.environment
  cluster_name                = "${var.environment}-cluster"
  cluster_version             = var.cluster_version
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  eks_nodes_security_group_id = module.vpc.eks_nodes_security_group_id
  eks_node_instance_types     = var.eks_node_instance_types
  eks_node_capacity           = var.eks_node_capacity
}

# Get OIDC provider for EKS
data "aws_iam_openid_connect_provider" "eks" {
  url = module.eks.cluster_oidc_issuer_url

  depends_on = [module.eks]
}

# External DNS Module
module "externaldns" {
  source = "../../modules/externaldns"

  environment       = var.environment
  cluster_name     = module.eks.cluster_name
  domain_names     = var.domain_names
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
}

# ACM Certificate Module
module "certificates" {
  source = "../../modules/acm"

  environment  = var.environment
  domain_names = ["nylabank.com", "*.nylabank.com"]
  zone_ids     = module.externaldns.hosted_zone_ids
}

# ALB Controller Module
module "alb_controller" {
  source = "../../modules/alb-controller"

  environment       = var.environment
  cluster_name     = module.eks.cluster_name
  vpc_id           = module.vpc.vpc_id
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
  certificate_arn   = module.certificates.certificate_arn
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment                  = var.environment
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  eks_nodes_security_group_id = module.vpc.eks_nodes_security_group_id
  instance_class              = var.rds_instance_class
  allocated_storage           = var.rds_allocated_storage
  engine_version              = var.rds_engine_version
  backup_retention_period     = var.rds_backup_retention
  multi_az                    = true
}

# Redis Module (ElastiCache for Production)
module "redis" {
  source = "../../modules/redis"

  environment                  = var.environment
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  eks_nodes_security_group_id = module.vpc.eks_nodes_security_group_id
  node_type                   = var.redis_node_type
  num_cache_nodes             = var.redis_num_cache_nodes
}

# ArgoCD Module
module "argocd" {
  source = "../../modules/argocd"

  environment      = var.environment
  cluster_name     = module.eks.cluster_name
  admin_password   = var.argocd_admin_password
  certificate_arn  = module.certificates.certificate_arn
}

# EKS Access Management
module "eks_access" {
  source = "../../modules/eks-access"

  environment        = var.environment
  cluster_name       = module.eks.cluster_name
  node_group_role_arn = module.eks.node_group_role_arn

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin1"
      username = "admin1"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DevOpsRole"
      username = "devops-role"
      groups   = ["system:masters"]
    }
  ]
}

module "ecr" {
  source = "../../modules/ecr"

  environment = "prod"
  repository_names = [
    "backend-api",
    "frontend-app"
  ]
  image_retention_count = 50  # Keep more images for prod
}