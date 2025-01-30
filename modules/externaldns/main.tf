# modules/externaldns/main.tf

terraform {
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

data "aws_region" "current" {}

# Instead of creating hosted zones, get the existing ones
data "aws_route53_zone" "zones" {
  for_each = toset(var.domain_names)
  name     = each.value
}

# IAM Policy for ExternalDNS
resource "aws_iam_policy" "external_dns" {
  name        = "${var.environment}-external-dns-policy"
  description = "Policy for ExternalDNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Actions = [
          "route53:ChangeResourceRecordSets"
        ]
        Resources = [
          for zone in data.aws_route53_zone.zones : "arn:aws:route53:::hostedzone/${zone.zone_id}"
        ]
      },
      {
        Effect = "Allow"
        Actions = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resources = [
          "*"
        ]
      }
    ]
  })
}

# IAM Role for ExternalDNS
resource "aws_iam_role" "external_dns" {
  name = "${var.environment}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, ":oidc-provider/", ":sub")}": "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  policy_arn = aws_iam_policy.external_dns.arn
  role       = aws_iam_role.external_dns.name
}

# Kubernetes Service Account
resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
}

# Helm Release for ExternalDNS
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.13.0"

  values = [
    yamlencode({
      serviceAccount: {
        create: false
        name: kubernetes_service_account.external_dns.metadata[0].name
      }
      provider: "aws"
      aws: {
        region: data.aws_region.current.name
        zoneType: "public"
      }
      domainFilters: var.domain_names
      txtOwnerId: var.environment
      policy: "sync"
      registry: "txt"
      interval: "1m"
      sources: [
        "ingress",
        "service"
      ]
      txtPrefix: "eks"
      rbac: {
        create: true
      }
      metrics: {
        enabled: true
        serviceMonitor: {
          enabled: true
        }
      }
      resources: {
        limits: {
          cpu: "100m"
          memory: "300Mi"
        }
        requests: {
          cpu: "50m"
          memory: "150Mi"
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.external_dns,
    kubernetes_service_account.external_dns
  ]
}

