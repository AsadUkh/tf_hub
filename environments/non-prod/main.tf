data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    bucket         = "terraform-state-nylabank"  
    key            = "non-prod/terraform.tfstate"
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
}

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

module "vpc" {
  source = "../../modules/vpc"

  environment = "non-prod"
  vpc_cidr    = "192.168.0.0/16"
  azs         = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source = "../../modules/eks"

  environment                  = "non-prod"
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  eks_nodes_security_group_id = module.vpc.eks_nodes_security_group_id
}

module "rds" {
  source = "../../modules/rds"

  environment                  = var.environment
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  eks_nodes_security_group_id = module.vpc.eks_nodes_security_group_id
  rds_instance_class          = var.rds_instance_class
  rds_allocated_storage       = var.rds_allocated_storage
  rds_engine_version          = var.rds_engine_version
  rds_backup_retention        = var.rds_backup_retention
  rds_multi_az               = var.rds_multi_az
  databases                  = var.databases
}



data "aws_eks_cluster" "main" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer

  depends_on = [module.eks]
}

module "alb_controller" {
  source = "../../modules/alb-controller"

  environment       = "non-prod"
  cluster_name     = module.eks.cluster_name
  vpc_id           = module.vpc.vpc_id
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
  certificate_arn = module.certificates.certificate_arn
}

module "externaldns" {
  source = "../../modules/externaldns"

  environment       = "non-prod"
  cluster_name     = module.eks.cluster_name
  domain_names     = var.domain_names
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
}

module "argocd" {
  source = "../../modules/argocd"

  environment      = "non-prod"
  cluster_name     = module.eks.cluster_name
  admin_password   = var.argocd_admin_password
  certificate_arn  = module.certificates.certificate_arn
}

module "certificates" {
  source = "../../modules/acm"

  environment = "non-prod"
  domain_names = [
    "*.dev.nylabank.com",
    "*.uat.nylabank.com",
    "dev.nylabank.com",
    "uat.nylabank.com"
  ]
  zone_ids = {
    "dev.nylabank.com" = module.externaldns.hosted_zone_ids["dev.nylabank.com"]
    "uat.nylabank.com" = module.externaldns.hosted_zone_ids["uat.nylabank.com"]
  }
}

module "eks_access" {
  source = "../../modules/eks-access"

  environment        = "non-prod"
  cluster_name       = module.eks.cluster_name
  node_group_role_arn = module.eks.node_group_role_arn  
  
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin1"
      username = "admin1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/dev1"
      username = "dev1"
      groups   = ["eks-developer"]
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

  environment = "non-prod"
  repository_names = [
    "backend-api",
    "frontend-app"
  ]
  image_retention_count = 20
}